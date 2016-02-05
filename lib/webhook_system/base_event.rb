module WebhookSystem

  # This is the class meant to be used as the base class for any Events sent through the Webhook system
  class BaseEvent
    include PhModel

    def event_name
      mesg = "class #{self.class.name} must implement abstract method `#{self.class.name}#event_name()'."
      raise RuntimeError.new(mesg).tap { |err| err.backtrace = caller }
    end

    def payload_attributes
      mesg = "class #{self.class.name} must implement abstract method `#{self.class.name}#payload_attributes()'."
      raise RuntimeError.new(mesg).tap { |err| err.backtrace = caller }
    end

    def as_json
      result = { 'event' => event_name }
      each_attribute do |attribute_name, attribute_method|
        validate_attribute_name attribute_name
        result[attribute_name.to_s] = public_send(attribute_method).as_json
      end
      result.deep_stringify_keys
    end

    def self.key_is_reserved?(key)
      key.to_s.in? %w(event)
    end

    private

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
