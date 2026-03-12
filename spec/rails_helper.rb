# frozen_string_literal: true

require 'spec_helper'
ENV['RAILS_ENV'] ||= 'test'

require File.expand_path('./internal/config/environment', __dir__)

# Prevent database truncation if the environment is production
raise('The Rails environment is running in production mode!') if Rails.env.production?

require 'rspec/rails'
require 'capybara/rails'
require 'capybara/rspec'
require 'selenium-webdriver'
require 'vcr'
# require 'billy/capybara/rspec'
require 'view_component/test_helpers'
require 'view_component/system_test_helpers'

require 'axe-capybara'
require 'axe-rspec'

VCR.configure do |c|
  # NOTE: uncomment this when creating or updating existing specs are wrapped in VCR.use_cassete
  # This will update the yaml files for the specs.
  # c.default_cassette_options = { record: :new_episodes }
  c.cassette_library_dir = 'spec/vcr'
  c.configure_rspec_metadata!
  c.hook_into :webmock
  c.ignore_localhost = true
  # ignore Solr, Capybara middleware, etc
  c.ignore_request do |request|
    # see https://github.com/oesmith/puffing-billy#working-with-vcr-and-webmock
    request.uri =~ /solr/ || request.uri =~ /chromedriver/ || request.headers.include?('Referer')
  end
end

Billy.configure do |c|
  c.cache = true
  c.cache_request_headers = false
  c.path_blacklist = []
  c.merge_cached_responses_whitelist = []
  c.persist_cache = true
  c.non_successful_cache_disabled = true
  c.non_successful_error_level = :error
  c.non_whitelisted_requests_disabled = false
  c.cache_path = 'spec/puffing_billy/req_cache/'
  c.certs_path = 'spec/puffing_billy/req_certs/'
end

# based on Billy::Browsers::Capybara#register_selenium_driver
# modified here to add window-size option
# (or some specs fail because smaller window hides responsive elements)
Capybara.register_driver :selenium_chrome_headless_billy do |app|
  options = Selenium::WebDriver::Chrome::Options.new
  options.add_argument('--headless=new')
  options.add_argument('--enable-features=NetworkService,NetworkServiceInProcess')
  options.add_argument('--ignore-certificate-errors')
  options.add_argument("--proxy-server=#{Billy.proxy.host}:#{Billy.proxy.port}")
  options.add_argument('--disable-gpu') if Gem.win_platform?
  options.add_argument('--no-sandbox') if ENV['CI']
  options.add_argument('--window-size=1024,768')

  Capybara::Selenium::Driver.new(
    app,
    browser: :chrome,
    options: options,
    clear_local_storage: true,
    clear_session_storage: true
  )
end

Capybara.javascript_driver = :selenium_chrome_headless_billy
Capybara.default_max_wait_time = 5

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
# Blacklight, again, make sure we're looking in the right place for em.
# Relative to HERE, NOT to Rails.root, which is off somewhere else.
Dir[Pathname.new(File.expand_path('support/**/*.rb', __dir__))].each { |f| require f }

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

  config.include ViewComponent::TestHelpers, type: :component
  config.include ViewComponent::SystemTestHelpers, type: :component
  config.include ViewComponentTestHelpers, type: :component
  config.include Capybara::RSpecMatchers, type: :component
end
