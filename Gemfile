# frozen_string_literal: true

source 'https://rubygems.org'

git_source(:github) { |repo| "https://github.com/boston-library/#{repo}.git" }

# Specify your gem's dependencies in commonwealth-vlr-engine.gemspec
gemspec

group :development, :test do
  gem 'rubocop', '~> 1.57.2', require: false
  gem 'rubocop-capybara', require: false
  gem 'rubocop-performance', '~> 1.19.1', require: false
  gem 'rubocop-rails', '~> 2.22.1', require: false
  gem 'rubocop-rspec', '~> 2.25.0', require: false
end

group :test do
  gem 'coveralls_reborn', '~> 0.28.0', require: false
  gem 'database_cleaner'
  gem 'puffing-billy'
  gem 'rails-controller-testing'
  gem 'rss'
  gem 'selenium-webdriver', '~> 4.26'
  gem 'simplecov'
  gem 'vcr', '~> 6.1'
  gem 'webmock', '~> 3.18'
end

# To use a debugger
# gem 'byebug', group: [:development, :test]

# BEGIN ENGINE_CART BLOCK
# engine_cart: 2.5.0
# engine_cart stanza: 2.5.0
# the below comes from engine_cart, a gem used to test this Rails engine gem in the context of a Rails app.
# file = File.expand_path('Gemfile', ENV.fetch('ENGINE_CART_DESTINATION') { ENV.fetch('RAILS_ROOT') { File.expand_path('.internal_test_app', File.dirname(__FILE__)) } })
# if File.exist?(file)
#   begin
#     eval_gemfile file
#   rescue Bundler::GemfileError => e
#     Bundler.ui.warn '[EngineCart] Skipping Rails application dependencies:'
#     Bundler.ui.warn e.message
#   end
# else
#   Bundler.ui.warn "[EngineCart] Unable to find test application dependencies in #{file}, using placeholder dependencies"
#   if ENV['RAILS_VERSION']
#     if ENV['RAILS_VERSION'] == 'edge'
#       gem 'rails', github: 'rails/rails'
#       ENV['ENGINE_CART_RAILS_OPTIONS'] = '--edge'
#     else
#       gem 'rails', ENV['RAILS_VERSION']
#     end
#   end
# end
# END ENGINE_CART BLOCK

# eval_gemfile File.expand_path("spec/internal/Gemfile", File.dirname(__FILE__))
