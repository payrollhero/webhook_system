module WebhookSystem

  # Main code that handles dispatching of events out to subscribers
  class Dispatcher
    class << self

      # @param [WebhookSystem::BaseEvent] event The Event Object
      def dispatch(event)
        WebhookSystem::Subscription.interested_in_topic(event.event_name).each do |subscription|
          WebhookSystem::Job.perform_later subscription, event.as_json
        end
      end

    end
  end
end
