module WebhookSystem
  class Subscription < ActiveRecord::Base
    self.table_name = 'webhook_subscriptions'

    validates :url, presence: true, url: { no_local: true }
    validates :secret, presence: true

    has_many :topics, class_name: 'WebhookSystem::SubscriptionTopic', dependent: :destroy
    accepts_nested_attributes_for :topics, allow_destroy: true

    scope :active, -> { where(active: true) }
    scope :for_topic, -> (topic) {
      joins(:topics).where(WebhookSystem::SubscriptionTopic.table_name => { name: topic })
    }

    scope :interested_in_topic, -> (topic) { active.for_topic(topic) }

    def url_domain
      URI.parse(url).host
    end

    def topic_names
      topics.map(&:name)
    end

    def topic_names=(new_topics)
      new_topics.reject!(&:blank?)
      add_topics = new_topics - topic_names

      new_topics_attributes = []

      topics.each do |topic|
        topic_attrs = {}
        topic_attrs[:id] = topic.id if topic.id
        if new_topics.include?(topic.name)
          topic_attrs[:name] = topic.name
        else
          topic_attrs[:_destroy] = true
        end
        new_topics_attributes << topic_attrs
      end

      add_topics.each do |topic|
        new_topics_attributes << { name: topic }
      end

      self.topics_attributes = new_topics_attributes
    end

  end
end
