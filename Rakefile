# frozen_string_literal: true

require 'bundler/gem_tasks'

require 'rubygems/tasks'
Gem::Tasks.new(release: false)

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new

task :test do
  sh "rspec"
  sh "rubocop"
end

task default: :spec

desc "copy in PayrollHero's current style config files"
task :styleguide do
  require 'faraday'
  require 'pry'
  base = "https://raw.githubusercontent.com/payrollhero/styleguide/master/"
  files = %w[
    .rubocop.hound.yml
    .rubocop.yml
    .codeclimate.yml
  ]
  files.each do |file|
    puts "Fetching #{file} ..."
    url = "#{base}#{file}"
    rsp = Faraday.get(url)
    unless rsp.status == 200
      warn "failing fetching: #{url}"
      warn "  response: #{rsp.status}: #{rsp.body}"
      exit 1
    end
    File.write(file, rsp.body)
  end
end

desc "Updates the changelog"
task :changelog do
  sh "github_changelog_generator payrollhero/webhook_system --simple-list"
end
