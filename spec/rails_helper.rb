ENV["RAILS_ENV"] ||= 'test'
require 'spec_helper'
require 'commonwealth-vlr-engine'
abort("The Rails environment is running in production mode!") if ::Rails.env.production?

require 'pry-rails'
require 'rspec/rails'
require 'capybara/rails'
require 'capybara/rspec'
require 'selenium/webdriver'

# Capybara.register_driver :poltergeist do |app|
#   options = {}
#   options[:js_errors] = false
#   options[:timeout] = 120 if RUBY_PLATFORM == "java"
#   options[:inspector] = true
#   options[:phantomjs_options] = ['--ignore-ssl-errors=yes']
#   options[:headers] = {"User-Agent" => "Poltergeist"}
#   Capybara::Poltergeist::Driver.new(app, options)
# end


# Capybara.default_driver = :poltergeist
# Capybara.javascript_driver = Capybara.default_driver
# Capybara.current_driver = Capybara.default_driver
# Capybara.default_max_wait_time = 5


Capybara.javascript_driver = :selenium_chrome_headless
Capybara.default_max_wait_time = 5


RSpec.configure do |config|
  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = false
  config.include Devise::Test::ControllerHelpers, type: :controller
  config.infer_spec_type_from_file_location!
  config.filter_rails_from_backtrace!

  config.before(:suite) do
    DatabaseCleaner.clean_with(:truncation)
  end

  config.before(:each) do
    DatabaseCleaner.strategy = :transaction
  end

  config.before(:each, :js => true) do
    DatabaseCleaner.strategy = :truncation
  end

  config.before(:each) do
    DatabaseCleaner.start
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end

  #JS Error Output
  config.after(:each, type: :feature, js: true) do
    errors = page.driver.browser.manage.logs.get(:browser)
    unless errors.blank?
      aggregate_failures 'javascript errrors' do
        errors.each do |error|
          STDERR.puts "#{error.level.upcase}: javascript warning"
          STDERR.puts error.message
        end
      end
    end
  end
end
