module WebhookSystem

  # This is the model holding on to all webhook responses
  class EventLog < ActiveRecord::Base
    self.table_name = 'webhook_event_logs'

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
        'body' => request.body,
        'url' => request.path,
      }
      response_info = {
        'headers' => response.headers.to_hash,
        'body' => response.body,
      }

      attributes = {
        event_name: event['event'],
        event_id: event['event_id'],
        status: response.status,
        request: request_info,
        response: response_info,
      }
      subscription.event_logs.build(attributes)
    end
  end
end
