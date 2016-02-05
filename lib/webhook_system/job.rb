module WebhookSystem

  # This is the ActiveJob in charge of actually sending each event
  class Job < ActiveJob::Base

    def perform(subscription, event)
      payload = Encoder.encode(subscription.secret, event)
      self.class.post(subscription.url, payload)
    end

    def self.post(endpoint, payload)
      client_for(endpoint).post do |req|
        req.headers['Content-Type'] = 'application/json; base64+aes256'
        req.body = payload.to_s
      end
    end

    def self.client_for(endpoint)
      Faraday.new(url: endpoint) do |faraday|
        faraday.response :logger if ENV['WEBHOOK_DEBUG']
        faraday.adapter Faraday.default_adapter
      end
    end

  end
end
