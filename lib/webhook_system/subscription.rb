module WebhookSystem
  class Subscription < ActiveRecord::Base
    self.table_name = 'webhook_subscriptions'

    validates :url, presence: true
    validates :secret, presence: true

    has_many :topics, class_name: 'WebhookSystem::SubscriptionTopic', dependent: :destroy

    scope :active, -> { where(active: true) }
    scope :for_topic, -> (topic) {
      joins(:topics).where(WebhookSystem::SubscriptionTopic.table_name => { name: topic })
    }

    scope :interested_in_topic, -> (topic) { active.for_topic(topic) }
  end
end
