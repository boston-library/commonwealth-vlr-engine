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

require 'engine_cart/rake_task'

require 'solr_wrapper'

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new

desc 'Run test suite'
task ci: ['engine_cart:generate'] do
  SolrWrapper.wrap do |solr|
    # TODO: below not needed because of TestAppGenerator#set_up_solr ?
    #Dir.glob(File.join(__dir__, 'lib', 'generators', 'commonwealth_vlr_engine', 'templates', 'solr', 'conf', '*.xml')) do |file|
    #  puts FileUtils.cp file, solr.config.collection_options[:dir]
    #end
    solr.with_collection do
      within_test_app do
        system 'RAILS_ENV=test rake commonwealth_vlr_engine:test_index:seed'
      end
      Rake::Task['spec'].invoke
    end
  end
end
