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
require 'vcr'
require 'billy/capybara/rspec'

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
    request.uri =~ /chromedriver/ || request.headers.include?('Referer')
  end
end

Billy.configure do |c|
  c.cache = true
  c.cache_request_headers = false
  # for AddThis social/sharing widget: app/views/catalog/_add_this.html.erb
  c.ignore_params = %w(
    https://s7.addthis.com/js/300/addthis_widget.js
    https://m.addthis.com/live/red_lojson/300lo.json
    https://s7.addthis.com/static/sh.f48a1a04fe8dbf021b4cda1d.html
    https://v1.addthisedge.com/live/boost/xa-505226a67a68dc99/_ate.track.config_resp
    https://z.moatads.com/addthismoatframe568911941483/moatframe.js
    https://m.addthis.com/live/red_lojson/100eng.json
  )
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
  options.headless!
  options.add_argument('--enable-features=NetworkService,NetworkServiceInProcess')
  options.add_argument('--ignore-certificate-errors')
  options.add_argument("--proxy-server=#{Billy.proxy.host}:#{Billy.proxy.port}")
  options.add_argument('--disable-gpu') if Gem.win_platform?
  options.add_argument('--no-sandbox') if ENV['CI']
  options.add_argument('--window-size=1024,768)')

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
