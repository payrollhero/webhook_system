# -*- encoding: utf-8 -*-

require File.expand_path('../lib/webhook_system/version', __FILE__)

Gem::Specification.new do |gem|
  gem.name = 'webhook_system'
  gem.version = WebhookSystem::VERSION
  gem.authors = ['Piotr Banasik', 'Mykola Kyryk']
  gem.email = 'piotr@payrollhero.com'

  gem.summary = 'Webhook system'
  gem.description = 'A pluggable webhook subscription system'
  gem.homepage = 'https://github.com/payrollhero/webhook_system'
  gem.license = 'MIT'

  gem.files = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  gem.bindir = 'exe'
  gem.executables = gem.files.grep(%r{^bin/}).map { |f| File.basename(f) }
  gem.require_paths = ['lib']

  gem.add_runtime_dependency 'activesupport', '> 3.2'#, '< 5.0' # have to drop support for ruby 2.1 if we enable 5.0
  gem.add_runtime_dependency 'activerecord', '> 3.2'#, '< 5.0' # have to drop support for ruby 2.1 if we enable 5.0
  gem.add_runtime_dependency 'activejob'
  gem.add_runtime_dependency 'attr_encrypted', '~> 3.1.0'
  gem.add_runtime_dependency 'faraday', '~> 1.3'
  gem.add_runtime_dependency 'faraday-encoding', '>= 0.0.2', '< 1.0'
  gem.add_runtime_dependency 'ph_model'
  gem.add_runtime_dependency 'validate_url', '~> 1.0'

  gem.add_development_dependency 'bundler', '> 1.0', '< 2.5'
  gem.add_development_dependency 'rake'
  gem.add_development_dependency 'rspec', '~> 3.0'
  gem.add_development_dependency 'rubygems-tasks', '~> 0.2'
  gem.add_development_dependency 'pry'
  gem.add_development_dependency 'sqlite3'
  gem.add_development_dependency 'github_changelog_generator', '~> 1.6'
  gem.add_development_dependency 'factory_girl'
  gem.add_development_dependency 'webmock'
  gem.add_development_dependency 'appraisal'

  # static analysis gems
  gem.add_development_dependency 'rubocop', '~> 0.48.1'
end
