# frozen_string_literal: true

FactoryBot.define do
  factory :webhook_event_log, class: WebhookSystem::EventLog do
    event_id { 1 }
    subscription_id { 1 }
    event_name { 'do_something' }
    status { 200 }
    request { { 'event' => 'body' } }
    response { { 'body' => 'ok' } }
  end

  factory :webhook_subscription, class: WebhookSystem::Subscription do
    url { 'http://lvh.me/webhook' }
    secret { 'some-secret' }
    active { false }

    trait :active do
      active { true }
    end

    trait :encrypted do
      encrypted { true }
    end

    trait :plain do
      encrypted { false }
    end

    trait :with_topics do
      transient do
        topics { [] }
      end

      after(:create) do |object, scope|
        scope.topics.each do |topic|
          object.topics.create!(name: topic)
        end
      end
    end
  end
end
