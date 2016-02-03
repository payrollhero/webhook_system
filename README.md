# webhook_system

* [Homepage](https://rubygems.org/gems/webhook_system)
* [Documentation](http://rubydoc.info/gems/webhook_system/frames)
* [Email](mailto:piotr.banasik at gmail.com)

## Description

[![Build Status](https://travis-ci.org/payrollhero/webhook_engine.svg?branch=master)](https://travis-ci.org/payrollhero/webhook_engine)
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

## Setup

The webhook integration code runs on two tables. You need to create a new migration that adds these
tables first:

```ruby
create_table :webhook_subscriptions do |t|
  t.string :url
  t.boolean :active
  t.text :secret

  t.index :active
end

create_table :webhook_subscription_topics do |t|
  t.string :name
  t.belongs_to :subscription

  t.index :subscription_id
  t.index :name
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
WebhookSystem.dispatch(event_object)
```

This is meant to be fairly fire and forget. Internally this will create an ActiveJob for each subscription
interested in the event.

## Payload Encryption

The payload is encrypted using AES-256. Each subscription is meant to have the recipient's shared secret on it.
This secret is then used to encrypt the payload, so the other side needs that same secret again to open it.

The payload then will be a json post body, with the Base64 encoded payload inside it.

## Payload Decryption

There is a utility function available to decode the entire POST body of the webhook that can be used by clients.

Example use would be:

```ruby
payload = WebhookSystem::Encoder.decode(secret_string, request.body)
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
