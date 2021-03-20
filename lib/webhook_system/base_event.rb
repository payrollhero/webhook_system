# frozen_string_literal: true

module WebhookSystem

  # This is the class meant to be used as the base class for any Events sent through the Webhook system
  class BaseEvent
    include PhModel

    def initialize(*args, &block)
      super(*args, &block)
      @event_id = SecureRandom.uuid.freeze
    end

    attr_reader :event_id

    def event_name
      # :nocov:
      mesg = "class #{self.class.name} must implement abstract method `#{self.class.name}#event_name()'."
      raise with_caller_backtrace(RuntimeError.new(mesg), 2)
      # :nocov:
    end

    def payload_attributes
      # :nocov:
      mesg = "class #{self.class.name} must implement abstract method `#{self.class.name}#payload_attributes()'."
      raise with_caller_backtrace(RuntimeError.new(mesg), 2)
      # :nocov:
    end

    def as_json
      result = {
        'event_name' => event_name,
        'event_id' => event_id,
        'data' => {}
      }
      each_attribute do |attribute_name, attribute_method|
        validate_attribute_name attribute_name
        result['data'][attribute_name.to_s] = public_send(attribute_method).as_json
      end
      result.deep_stringify_keys
    end

    def self.key_is_reserved?(key)
      key.to_s.in? %w[event event_id]
    end

    def self.dispatch(args)
      WebhookSystem::Subscription.global.dispatch build(args)
    end

    private

    def with_caller_backtrace(exception, backtrack = 2)
      # :nocov:
      exception.set_backtrace(caller[backtrack..])
      exception
      # :nocov:
    end

    def validate_attribute_name(key)
      return unless self.class.key_is_reserved?(key)

      message = "#{self.class.name} should not be defining an attribute named #{key} since its reserved"
      raise ArgumentError, message

    end

    def each_attribute(&block)
      case payload_attributes
      when Array
        payload_attributes.each do |attribute_name|
          yield(attribute_name, attribute_name)
        end
      when Hash
        payload_attributes.each(&block)
      else
        # :nocov:
        raise ArgumentError, "don't know how to deal with payload_attributes: #{payload_attributes.inspect}"
        # :nocov:
      end
    end
  end
end
