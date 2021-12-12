# frozen_string_literal: true

module WebhookSystem

  # This is the ActiveJob in charge of actually sending each event
  class Job < ActiveJob::Base

    # Exception class around non 200 responses
    class RequestFailed < RuntimeError
      def initialize(message, code, error_message = nil)
        super(message)
        @code = code
        @error_message = error_message
      end
    end

    # Represents response for an exception we get when doing Faraday http call
    class ErrorResponse
      def initialize(exception)
        @exception = exception
      end

      def status
        0 # no HTTP response status as we got an exception while trying to perform the request
      end

      def headers
        {}
      end

      def body
        [@exception.class.name, @exception.message, *@exception.backtrace].join("\n")
      end
    end

    def perform(subscription, event)
      if subscription.url.match?(/^https?:/)
        self.class.post(subscription, event)
      elsif (match_data = subscription.url.match(/^inline:(.*)/)).present?
        self.class.call_inline(match_data[1], subscription, event)
      else
        raise RuntimeError, "unknown prefix url for subscription"
        ensure_success(ErrorResponse.new(exception), :INVALID, subscription)
      end
    end

    def self.call_inline(job_name, subscription, event)
      # subscription url could contain a job name, or a ruby class/method call
      # how do we sanitize this not to be allowing hackers to call arbitrary code via
      # a subscription? maybe a prefix is enough?
      job_class = const_get("WebhookSystem::Inline#{job_name}Job")
      job_class.perform_now(subscription, event)
    end

    def self.post(subscription, event)
      client = build_client(subscription)
      request = build_request(client, subscription, event)

      response =
        begin
          client.builder.build_response(client, request)
        rescue RuntimeError => e
          ErrorResponse.new(e)
        end

      log_response(subscription, event, request, response)
      ensure_success(response, :POST, subscription)
    end

    def self.ensure_success(response, http_method, subscription)
      url = subscription.url
      status = response.status
      return if (200..299).cover? status

      if subscription.respond_to?(:account_id)
        account_info = subscription.account_info
        inner = "failed for account #{account_info} with"
      else
        inner = "failed with"
      end
      text = "#{http_method} request to #{url} #{inner} code: #{status} and error #{response.body}"
      raise RequestFailed.new(text, status, response.body)

    end

    def self.build_request(client, subscription, event)
      payload, headers = Encoder.encode(subscription.secret, event, format: format_for_subscription(subscription))
      client.build_request(:post) do |req|
        req.url subscription.url
        req.headers.merge!(headers)
        req.body = payload.to_s
      end
    end

    def self.format_for_subscription(subscription)
      subscription.encrypted ? 'base64+aes256' : 'json'
    end

    def self.log_response(subscription, event, request, response)
      event_log = EventLog.construct(subscription, event, request, response)

      # we write log in a separate thread to make sure it is created even if the whole job fails
      # Usually any background job would be wrapped into transaction,
      # so if the job fails we would rollback any DB changes, including the even log record.
      # We want the even log record to always be created, so we check if we are running inside the transaction,
      # if we are - we create the record in a separate thread. New Thread means a new DB connection and
      # ActiveRecord transactions are per connection, which gives us the "transaction jailbreak".
      if ActiveRecord::Base.connection.open_transactions.zero?
        event_log.save!
      else
        Thread.new { event_log.save! }.join
      end
    end

    def self.build_client(subscription)
      Faraday.new do |faraday|
        faraday.response :logger if ENV['WEBHOOK_DEBUG']
        # use Faraday::Encoding middleware
        faraday.response :encoding
        faraday.adapter Faraday.default_adapter
        if subscription.auth_enabled && subscription.username.present? && subscription.password.present?
          faraday.request :basic_auth, subscription.username, subscription.password
        end
      end
    end
  end
end
