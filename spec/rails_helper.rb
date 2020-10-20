# frozen_string_literal: true

ENV['RAILS_ENV'] ||= 'test'
require 'spec_helper'
require 'commonwealth-vlr-engine'
abort('The Rails environment is running in production mode!') if ::Rails.env.production?

require 'engine_cart'
EngineCart.load_application!

require 'pry-rails'
require 'rspec/rails'
require 'capybara/rails'
require 'capybara/rspec'
require 'webdrivers'

Capybara.register_driver :selenium_chrome_headless do |app|
  capabilities = Selenium::WebDriver::Remote::Capabilities.chrome(
    chromeOptions: { args: %w(headless disable-gpu window-size=1024,768) }
  )
  Capybara::Selenium::Driver.new app, browser: :chrome, desired_capabilities: capabilities
end

Capybara.javascript_driver = :selenium_chrome_headless
Capybara.default_max_wait_time = 5

RSpec.configure do |config|
  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = false
  config.infer_spec_type_from_file_location!
  config.filter_rails_from_backtrace!

  config.before(:suite) do
    DatabaseCleaner.clean_with(:truncation)
  end

  config.before(:each) do
    DatabaseCleaner.strategy = :transaction
  end

  config.before(:each, js: true) do
    DatabaseCleaner.strategy = :truncation
  end

  config.before(:each) do
    DatabaseCleaner.start
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end
end
