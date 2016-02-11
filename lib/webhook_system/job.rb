module WebhookSystem

  # This is the ActiveJob in charge of actually sending each event
  class Job < ActiveJob::Base

    # Exception class around non 200 responses
    class RequestFailed < RuntimeError
      def initialize(message, code)
        super(message)
        @code = code
      end
    end

    def perform(subscription, event)
      self.class.post(subscription, event)
    end

    def self.post(subscription, event)
      client = build_client
      request = build_request(client, subscription, event)
      response = client.builder.build_response(client, request)
      log_response(subscription, event, request, response)
      ensure_success(response)
    end

    def self.ensure_success(response)
      status = response.status
      unless status == 200
        raise RequestFailed.new("request failed with code: #{status}", status)
      end
    end

    def self.build_request(client, subscription, event)
      payload = Encoder.encode(subscription.secret, event)
      client.build_request(:post) do |req|
        req.url subscription.url
        req.headers['Content-Type'] = 'application/json; base64+aes256'
        req.body = payload.to_s
      end
    end

    def self.log_response(subscription, event, request, response)
      EventLog.construct(subscription, event, request, response).save!
    end

    def self.build_client
      Faraday.new do |faraday|
        faraday.response :logger if ENV['WEBHOOK_DEBUG']
        faraday.adapter Faraday.default_adapter
      end
    end

  end
end
