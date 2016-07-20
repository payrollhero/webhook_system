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
      mesg = "class #{self.class.name} must implement abstract method `#{self.class.name}#event_name()'."
      raise with_caller_backtrace(RuntimeError.new(mesg), 2)
    end

    def payload_attributes
      mesg = "class #{self.class.name} must implement abstract method `#{self.class.name}#payload_attributes()'."
      raise with_caller_backtrace(RuntimeError.new(mesg), 2)
    end

    def as_json
      result = {
        'event_name' => event_name,
        'event_id' => event_id,
      }
      each_attribute do |attribute_name, attribute_method|
        validate_attribute_name attribute_name
        result[attribute_name.to_s] = public_send(attribute_method).as_json
      end
      result.deep_stringify_keys
    end

    def self.key_is_reserved?(key)
      key.to_s.in? %w(event event_id)
    end

    private

    def with_caller_backtrace(exception, backtrack=2)
      exception.set_backtrace(caller[backtrack..-1])
      exception
    end

    def validate_attribute_name(key)
      if self.class.key_is_reserved?(key)
        message = "#{self.class.name} should not be defining an attribute named #{key} since its reserved"
        raise ArgumentError, message
      end
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
        raise ArgumetError, "don't know how to deal with payload_attributes: #{payload_attributes.inspect}"
      end
    end
  end
end
