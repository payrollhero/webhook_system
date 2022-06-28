# frozen_string_literal: true

# Just Rspec helpers for DB
module DatabaseSupport
  def with_clean_database
    database_filename = 'test.db'
    FileUtils.rm_rf(database_filename)
    ActiveRecord::Base.establish_connection adapter: :sqlite3, database: database_filename
    ActiveRecord::Migration.suppress_messages do
      load('spec/db/schema.rb')
    end
    yield
  ensure
    FileUtils.rm_rf(database_filename)
  end

  module_function :with_clean_database
end
