module WebhookSystem

  # This is the model encompassing the actual record of a webhook subscription
  class Subscription < ActiveRecord::Base
    self.table_name = 'webhook_subscriptions'

    validates :url, presence: true, url: { no_local: true }
    validates :secret, presence: true

    has_many :topics, class_name: 'WebhookSystem::SubscriptionTopic', dependent: :destroy
    has_many :event_logs, class_name: 'WebhookSystem::EventLog', dependent: :destroy

    accepts_nested_attributes_for :topics, allow_destroy: true

    scope :active, -> { where(active: true) }
    scope :for_topic, -> (topic) {
      joins(:topics).where(WebhookSystem::SubscriptionTopic.table_name => { name: topic })
    }

    scope :interested_in_topic, -> (topic) { active.for_topic(topic) }

    # Just a helper to get a nice representation of the subscription
    def url_domain
      URI.parse(url).host
    end

    # Abstraction around the topics relation, returns an array of the subscribed topic names
    def topic_names
      topics.map(&:name)
    end

    # Abstraction around the topics relation, sets the topic names, requires save to take effect
    def topic_names=(new_topics)
      new_topics.reject!(&:blank?)
      add_topics = new_topics - topic_names

      new_topics_attributes = []

      topics.each do |topic|
        new_topics_attributes << {
          id: topic.id,
          name: topic.name,
          _destroy: !new_topics.include?(topic.name),
        }
      end

      new_topics_attributes += add_topics.map { |topic| { name: topic } }

      self.topics_attributes = new_topics_attributes
    end

  end
end
