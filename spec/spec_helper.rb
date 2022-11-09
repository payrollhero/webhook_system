# frozen_string_literal: true

require 'bundler/setup'

require 'simplecov'
require 'coveralls'

if RUBY_VERSION < "3.1"
  SimpleCov.start 'rails' do
    if ENV['CI']
      require 'simplecov-lcov'

      SimpleCov::Formatter::LcovFormatter.config do |c|
        c.report_with_single_file = true
        c.single_report_path = 'coverage/lcov.info'
      end

      formatter SimpleCov::Formatter::LcovFormatter
    end

    add_filter '/bin/'
    add_filter '/script/'
    add_filter '/db/'
    add_filter '/spec/' # for rspec
    add_filter '/test/' # for minitest
  end

  Coveralls.wear!('rails')
end

# Load the gem
require 'webhook_system'

# Load Test Helpers
require 'webmock/rspec'
require 'factory_bot'

# Load support
Dir['./spec/support/**/*.rb'].sort.each do |filename|
  require filename
end

# Boot up globalid in ActiveRecord (Rails will do this normally)
GlobalID.app = 'WebhookSystem'
ActiveSupport.on_load(:active_record) do
  require 'global_id/identification'
  send :include, GlobalID::Identification
end

# Setup ActiveJob
ActiveJob::Base.queue_adapter = :test
ActiveJob::Base.logger = Logger.new($stderr).tap { |logger| logger.level = Logger::ERROR }

RSpec.configure do |config|
  config.include DatabaseSupport, db: true
  config.include FactoryBot::Syntax::Methods
  config.include ActiveJob::TestHelper

  config.around(:each, db: true) do |example|
    with_clean_database do
      example.call
    end
  end

  config.before(:suite) do
    DatabaseSupport.with_clean_database do
      FactoryBot.lint
    end
  end
end
