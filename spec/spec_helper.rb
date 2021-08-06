require 'bundler/setup'

# Load the gem
require 'webhook_system'

# Load Test Helpers
require 'webmock/rspec'
require 'factory_bot'

# Helpers
require 'pry'

# Load support
Dir['./spec/support/**/*.rb'].each do |filename|
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
