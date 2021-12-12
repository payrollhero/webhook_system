# frozen_string_literal: true

module WebhookSystem

  # This is the model encompassing the actual record of a webhook subscription
  class Subscription < ActiveRecord::Base
    self.table_name = 'webhook_subscriptions'

    belongs_to :account if defined?(Account)

    INLINE_JOB_REGEXP = /^inline:(.*)/.freeze
    validates :url, presence: true, url: { no_local: true }, if: proc { |a| !a.url.match?(INLINE_JOB_REGEXP) }
    validates :secret, presence: true
    attr_encrypted :password, key: Base64.decode64(Rails.application.secrets[:encrypted_key])

    has_many :topics, class_name: 'WebhookSystem::SubscriptionTopic', dependent: :destroy
    has_many :event_logs, class_name: 'WebhookSystem::EventLog', dependent: :delete_all

    accepts_nested_attributes_for :topics, allow_destroy: true

    scope :active, -> { where(active: true) }
    scope :for_topic, ->(topic) {
      joins(:topics).where(WebhookSystem::SubscriptionTopic.table_name => { name: topic })
    }

    scope :interested_in_topic, ->(topic) { active.for_topic(topic) }

    # Main invocation point for dispatching events, can either be called on the class
    # or on a relation (ie a scoped down list of subs), will find applicable subs and dispatch to them
    #
    # @param [WebhookSystem::BaseEvent] event The Event Object
    def self.dispatch(event)
      interested_in_topic(event.event_name).each do |subscription|
        WebhookSystem::Job.perform_later subscription, event.as_json
      end
    end

    # Just a helper to get a nice representation of the subscription
    def url_domain
      if data = url.match(INLINE_JOB_REGEXP)
        data[1]
      else
        URI.parse(url).host
      end
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
          _destroy: new_topics.exclude?(topic.name),
        }
      end

      new_topics_attributes += add_topics.map { |topic| { name: topic } }

      self.topics_attributes = new_topics_attributes
    end

    def account_info
      if defined?(Account)
        "#{account_id}:#{account.try(:name)}"
      else
        account_id.to_s
      end
    end
  end
end
