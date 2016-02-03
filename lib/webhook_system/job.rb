module WebhookSystem

  # This is the ActiveJob in charge of actually sending each event
  class Job < ActiveJob::Base

    def perform(subscription, event)
      payload = Encoder.encode(subscription.secret, event)
      client = HttpClient.new(subscription.url)
      client.post(payload)
    end

  end

  # Just a simple internal class to wrap around the http requests to the endpoints
  class HttpClient
    def initialize(endpoint)
      @endpoint = endpoint
    end

    def post(payload)
      client.post do |req|
        req.headers['Content-Type'] = 'application/json; base64+aes256'
        req.body = payload.to_s
      end
    end

    private

    attr_reader :endpoint, :client

    def client
      @client ||= Faraday.new(url: endpoint) do |faraday|
        # faraday.request :url_encoded # form-encode POST params
        faraday.response :logger # log requests to STDOUT
        faraday.adapter Faraday.default_adapter
      end
    end
  end
end
