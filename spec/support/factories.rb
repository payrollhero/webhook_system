FactoryGirl.define do
  factory :webhook_subscription, class: WebhookSystem::Subscription do
    url 'http://lvh.me/webhook'
    secret 'some-secret'
    active false

    trait :active do
      active true
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
