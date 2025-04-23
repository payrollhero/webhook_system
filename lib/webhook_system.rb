# frozen_string_literal: true

require 'active_support/all'
require 'active_record'
require 'active_job'
require 'ph_model'
require 'validate_url'
require 'faraday'
require 'faraday-encoding'

module WebhookSystem
  extend ActiveSupport::Autoload

  autoload :Subscription
  autoload :Dispatcher
  autoload :SubscriptionTopic
  autoload :Job
  autoload :Encoder
  autoload :BaseEvent
  autoload :EventLog

  # Error raised when there is an issue with decoding the payload
  class DecodingError < RuntimeError
  end
end
