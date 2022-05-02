# webhook_system

* [Homepage](https://rubygems.org/gems/webhook_system)
* [Documentation](http://rubydoc.info/gems/webhook_system/frames)
* [Email](mailto:piotr.banasik at gmail.com)

## Description

[![Build Status](https://travis-ci.org/payrollhero/webhook_system.svg?branch=master)](https://travis-ci.org/payrollhero/webhook_system)
[![Code Climate](https://codeclimate.com/github/payrollhero/webhook_system/badges/gpa.svg)](https://codeclimate.com/github/payrollhero/webhook_system)
[![Issue Count](https://codeclimate.com/github/payrollhero/webhook_system/badges/issue_count.svg)](https://codeclimate.com/github/payrollhero/webhook_system)
[![Dependency Status](https://gemnasium.com/payrollhero/webhook_system.svg)](https://gemnasium.com/payrollhero/webhook_system)

## Overview

Few Main points ..

1. The "server" holds on to a record of subscriptions
2. Each subscription has a secret attached to it
3. This secret is used to encrypt the entire payload of the webhook using AES-256
4. The webhook is delivered to the recipient as a JSON payload with a base64 encoded data component
5. The recipient is meant to use their copy of this secret to decode that payload, and then action it as needed.

## Upgrading

If you are upgrading from <= 2.3.1 into >= 2.4, then you must run a migration to rename the `encrypt` column.
This rename was required for adding support for Rails 7.

You can use this migration.

```ruby
# db/migrate/20220427113942_rename_encrypt_on_webhook_subscriptions.rb
class RenameEncryptOnWebhookSubscriptions < ActiveRecord::Migration[7.0]
  def change
    rename_column :webhook_subscriptions, :encrypt, :encrypted
  end
end
```

## Setup

The webhook integration code runs on two tables. You need to create a new migration that adds these
tables first:

```ruby
create_table :webhook_subscriptions do |t|
  t.string :url, null: false
  t.boolean :active, null: false, index: true
  t.boolean :encrypted, null: false, default: false
  t.text :secret
end

create_table :webhook_subscription_topics do |t|
  t.string :name, null: false, index: true
  t.belongs_to :subscription, null: false, index: true
end

create_table :webhook_event_logs do |t|
  t.belongs_to :subscription, null: false, index: true

  t.string :event_name, null: false, index: true
  t.string :event_id, null: false, index: true
  t.integer :status, null: false, index: true

  t.text :request, limit: 64_000, null: false
  t.text :response, limit: 64_000, null: false

  t.datetime :created_at, null: false, index: true
end
```

### Migrating from version 1.x

The main new change is the addition of a new 'encrypt' column on subscriptions

Add this migration to get this added (and retain original behavior)

```ruby
def change
  add_column :webhook_subscriptions, :encrypt, :boolean, default: true, null: false, after: :active
end
```

### Migrating from version 0.x

First migrate the null constraints in ...

```ruby
def up
  change_column :webhook_subscriptions, :url, :string, null: false
  change_column :webhook_subscriptions, :active, :boolean, null: false
  change_column :webhook_subscription_topics, :name, :string, null: false
  change_column :webhook_subscription_topics, :subscription_id, :integer, null: false
end

def down
  change_column :webhook_subscription_topics, :subscription_id, :integer, null: true
  change_column :webhook_subscription_topics, :name, :string, null: true
  change_column :webhook_subscriptions, :active, :boolean, null: true
  change_column :webhook_subscriptions, :url, :string, null: true
end
```

Then add the new table ...

```ruby
create_table :webhook_event_logs do |t|
  t.belongs_to :subscription, null: false

  t.string :event_name, null: false
  t.string :event_id, null: false
  t.integer :status, null: false

  t.text :request, limit: 64_000, null: false
  t.text :response, limit: 64_000, null: false

  t.datetime :created_at, null: false

  t.index :created_at
  t.index :event_name
  t.index :status
  t.index :subscription_id
  t.index :event_id
end
```

## Configuring the ActiveJob Job

There is a couple of things you might need to configure in your handling of these jobs

### Queue Name

You might need to reopen the class and define the queue:

eg:
```ruby
class WebhookSystem::Job
  queue_as :some_queue_name
end
```

### Error Handling

By default the job will fail itself when it gets a non 200 response. You can handle these errors by rescuing the
Request failed exception. eg:

```ruby
class WebhookSystem::Job
  rescue_from(WebhookSystem::Job::RequestFailed) do |exception|
    case exception.code
    when 200..299
      # this is ok, ignore it
    when 300..399
      # this is kinda ok, but let's log it ..
      Rails.logger.info "weird response"
    else
      # otherwise re-raise it so the job fails
      raise exception
    end
  end
end
```

## Building Events

Each event type should be a discrete class inheriting from `WebhookSystem::BaseEvent`.

Each class should define `event_name` and `payload_attributes` to set up the serializer properly.

### Payload Attributes

It seems worth mentioning a bit more about these. This whole system in the event is an abstraction system around
cleanly serializing these objects. The attribute list can take two forms:

Either as a simple array:

```ruby
  def payload_attributes
    [
      :widget,
      :name,
    ]
  end
```

This version just maps 1:1 the attribute to a method on the event. This means that in this example it'd expect
`widget` and `name` to be public methods on the event.

The alternate form is to use a Hash.

eg:
```ruby
  def payload_attributes
    {
      widget: :get_widget,
      name: :get_name,
    }
  end
```

This version makes the keys the attributes in the JSON, and the values the method names to call to get the value.

### Working with Events

The general idea is that Events are ActiveModel objects using the PhModel system, so the same APIs apply.

You'd build them with `.build`. Eg:

```ruby
event_object = SomeEvent.build(name: 'John', age: 21)
```

These attributes shouldn't necessarily be already the direct data hashes, let the Event do its own presentation.
Its perfectly OK to send these events with ActiveRecord parameters, and internally translate out of them to something
more suitable for the actual notification payload.

## Dispatching Events

The general API for this is via:

```ruby
WebhookSystem::Subscription.dispatch(event_object)
```

This is meant to be fairly fire and forget. Internally this will create an ActiveJob for each subscription
interested in the event.

### Dispatching to Selected Subscriptions

There may be scenarios where you extended the Subscription model, and may need to only dispatch to a subset of subs.
For example, if you attached a relation to say Account. The `dispatch` method is actually defined to work with any
subscription relation. eg:

```ruby
account = Account.find(1) # assume we have some model called Account
subs = account.webhook_subscriptions # and we added a column to webhook_subscriptions to accomodate this extra relation
subs.dispatch(some_event) # you can dispatch to just those subscriptions (it will filter for the specific ones)
                          # that are actually interested in the event
```

### Checking if any sub is interested

There may scenarios, where you really don't want to do some additional work unless you really have an event to dispatch.
You can check pretty quickly if there is any topics interested liks so:

```ruby
if WebhookSystem::Subscription.interested_in_topic('some_topic').present?
  # do some stuff
end
```

This also works with selected subscriptions like in the example above:

```ruby
account = Account.find(1) # assume we have some model called Account
subs = account.webhook_subscriptions # and we added a column to webhook_subscriptions to accomodate this extra relation
if subs.interested_in_topic('some_topic').present?
  subs.dispatch(SomeEvent.build(some_expensive_function()))
end
```

# Payload Format

Payloads can either be plain json or encrypted. On top of that, they're also signed. The format for the signature
follows GitHub's own format: [https://developer.github.com/webhooks/securing/](https://developer.github.com/webhooks/securing/).
The subscription's secret is used to create the signature.

The payload can be encrypted based on the `encrypt` boolean column of a subscription.

## Payload Verification

This library can be used as a helper to decode and verify the payloads as well. The same usage as the Decryption below
will also verify the signature if present in the headers passed.

## Payload Encryption

The payload can be encrypted using AES-256. Each subscription is meant to have the recipient's shared secret on it.
This secret is then used to encrypt the payload, so the other side needs that same secret again to open it.

The payload then will be a json post body, with the Base64 encoded payload inside it.

## Payload Decryption

There is a utility function available to decode the entire POST body of the webhook that can be used by clients.

Example use would be:

```ruby
payload = WebhookSystem::Encoder.decode(secret_string, request.body, request.headers)
```

You will need your webhook secret, and you get back a Hash of the event's data.
All events are guaranteed to have a key called `event` with the event's name, everything other than that is
custom to each individual event type.

Some more specifics around the format for the benefit of non-ruby implementations:

The payload looks like this:

```json
{
  "format": "base64+aes256",
  "payload": "{Base64 String}",
  "iv": "{Base64 String}"
}
```

The format is just a flag incase there ever is multiple formats, currently this is the only one.

The encryption used is AES256-CBC

The AES key is a PBKDF2 (Password-Based Key Derivation Function 2) as part of PKCS#5 function on the secret using
SHA256 HMAC. The IV is used as the salt, 100_000 iterations, and a key length of 32 bytes (or 256 bits).

The IV is used both for initializing the cipher, and also for salting the password PBKDF2 function.

## Copyright

Copyright (c) 2015 PayrollHero
