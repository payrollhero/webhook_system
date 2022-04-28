# frozen_string_literal: true

module WebhookSystem

  # This is the model holding on to all webhook responses
  class EventLog < ActiveRecord::Base
    self.table_name = 'webhook_event_logs'

    MAX_JSON_ATTRIBUTE_SIZE = 40_000

    belongs_to :subscription, class_name: 'WebhookSystem::Subscription'

    validates :event_id, presence: true
    validates :subscription_id, presence: true
    validates :event_name, presence: true
    validates :status, presence: true

    serialize :request, JSON
    serialize :response, JSON

    def self.construct(subscription, event, request, response)
      request_info = {
        'event' => event,
        'headers' => request.headers.to_hash,
        'body' => request.body.truncate(MAX_JSON_ATTRIBUTE_SIZE),
        'url' => request.path
      }
      response_info = {
        'headers' => response.headers.to_hash,
        'body' => response.body.truncate(MAX_JSON_ATTRIBUTE_SIZE)
      }

      attributes = {
        event_name: event['event_name'],
        event_id: event['event_id'],
        status: response.status,
        request: request_info,
        response: response_info
      }
      subscription.event_logs.build(attributes)
    end
  end
end
