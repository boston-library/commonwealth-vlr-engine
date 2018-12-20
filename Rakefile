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
    FileUtils.cp File.join(__dir__, 'lib', 'generators', 'commonwealth_vlr_engine', 'templates', 'solr', 'conf'),
                 File.join(solr.instance_dir, 'conf')
    solr.with_collection do
      within_test_app do
        system 'RAILS_ENV=test rake commonwealth_vlr_engine:test_index:seed'
      end
      Rake::Task['spec'].invoke
    end
  end
end

=begin
-------------------------------
require "bundler/gem_tasks"

ZIP_URL = "https://github.com/projectblacklight/blacklight-jetty/archive/v4.6.0.zip"
APP_ROOT = File.dirname(__FILE__)

require 'rspec/core/rake_task'
require 'engine_cart/rake_task'

require 'jettywrapper'

task default: :ci

RSpec::Core::RakeTask.new(:spec)

desc "Load fixtures"
task :fixtures => ['engine_cart:generate'] do
  EngineCart.within_test_app do
    system "rake vlr_engine:test_index:seed RAILS_ENV=test"
  end
end

desc "Execute Continuous Integration build"
task :ci => ['engine_cart:generate', 'jetty:clean', 'commonwealth_vlr_engine:configure_jetty'] do

  require 'jettywrapper'
  jetty_params = Jettywrapper.load_config('test')

  error = Jettywrapper.wrap(jetty_params) do
    Rake::Task['fixtures'].invoke
    Rake::Task['spec'].invoke
  end
  raise "test failures: #{error}" if error
end


namespace :commonwealth_vlr_engine do
  desc "Copies the default SOLR config for the bundled Testing Server"
  task :configure_jetty do
    FileList['solr_conf/conf/*'].each do |f|
      cp("#{f}", 'jetty/solr/blacklight-core/conf/', :verbose => true)
    end
  end
end
=end
