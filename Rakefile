# frozen_string_literal: true

require 'rubygems'
begin
  require 'bundler/setup'
rescue LoadError
  puts 'You must `gem install bundler` and `bundle install` to run rake tasks'
end

require 'rdoc/task'
RDoc::Task.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'CommonwealthVlrEngine'
  rdoc.options << '--line-numbers'
  rdoc.rdoc_files.include('README.rdoc')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

Bundler::GemHelper.install_tasks

Rake::Task.define_task(:environment)

load 'lib/railties/commonwealth_vlr_engine.rake'

task default: :ci

require 'solr_wrapper'

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new

require 'rubocop/rake_task'
RuboCop::RakeTask.new(:rubocop) do |task|
  task.requires << 'rubocop-rails'
  task.requires << 'rubocop-rspec'
  task.requires << 'rubocop-performance'
  task.fail_on_error = true
  # WARNING: Make sure the bottom 3 lines are always commented out before committing
  # task.options << '--safe-auto-correct'
  # task.options << '--disable-uncorrectable'
  # task.options << '-d'
end

desc 'Lint, set up test app, spin up Solr, and run test suite'
task ci: [:rubocop] do
  SolrWrapper.wrap do |solr|
    solr.with_collection do
      within_test_app do
        system 'RAILS_ENV=test rake commonwealth_vlr_engine:test_index:seed'
      end
      Rake::Task['spec'].invoke
    end
  end
end
