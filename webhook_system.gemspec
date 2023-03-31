# -*- encoding: utf-8 -*-

require File.expand_path('../lib/webhook_system/version', __FILE__)

Gem::Specification.new do |gem|
  gem.name = 'webhook_system'
  gem.version = WebhookSystem::VERSION
  gem.authors = ['Piotr Banasik', 'Mykola Kyryk']
  gem.email = 'dev@payrollhero.com'

  gem.summary = 'Webhook system'
  gem.description = 'A pluggable webhook subscription system'
  gem.homepage = 'https://github.com/payrollhero/webhook_system'
  gem.license = 'MIT'

  gem.files = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  gem.bindir = 'exe'
  gem.executables = gem.files.grep(%r{^bin/}).map { |f| File.basename(f) }
  gem.require_paths = ['lib']

  gem.post_install_message = %q{
    ## Upgrading

    If you are upgrading from <= 2.3.1 into >= 2.4, then you must run a migration to rename the `encrypt` column.
    This rename was required for adding support for Rails 7.

    You can use this migration.

    ```ruby
    # db/migrate/20220427113942_rename_encrypt_on_webhook_subscriptions.rb
    class RenameEncryptOnWebhookSubscriptions < ActiveRecord::Migration[7.0]
      def change
        rename_column :webhook_subscriptions, :encrypt, :encrypted
      end
    end
    ```
  }

  gem.required_ruby_version = '> 2.6.2'
  gem.add_runtime_dependency 'activesupport', '> 4.2', '< 7.1'
  gem.add_runtime_dependency 'activerecord', '> 4.2', '< 7.1'
  gem.add_runtime_dependency 'activejob', '> 4.2', '< 7.1'
  gem.add_runtime_dependency 'faraday', '> 0.9'
  gem.add_runtime_dependency 'faraday-encoding', '>= 0.0.2', '< 1.0'
  gem.add_runtime_dependency 'ph_model'
  gem.add_runtime_dependency 'validate_url', '~> 1.0'

  gem.add_development_dependency 'bundler', '> 1.17', '< 2.5'
  gem.add_development_dependency 'coveralls_reborn', '~> 0.25'
  gem.add_development_dependency 'simplecov-lcov'
  gem.add_development_dependency 'rake'
  gem.add_development_dependency 'rspec', '~> 3.0'
  gem.add_development_dependency 'rubygems-tasks', '~> 0.2'
  gem.add_development_dependency 'sqlite3'
  gem.add_development_dependency 'github_changelog_generator', '~> 1.6'
  gem.add_development_dependency 'factory_bot'
  gem.add_development_dependency 'webmock'

  # static analysis gems
  gem.add_development_dependency 'rubocop_challenger'
end
