# frozen_string_literal: true

source 'https://rubygems.org'

git_source(:github) { |repo| "https://github.com/boston-library/#{repo}.git" }

# Specify your gem's dependencies in commonwealth-vlr-engine.gemspec
gemspec

group :development, :test do
  gem 'rubocop', '~> 1.61.0', require: false
  gem 'rubocop-capybara', require: false
  gem 'rubocop-performance', '~> 1.19.1', require: false
  gem 'rubocop-rails', '~> 2.22.1', require: false
  gem 'rubocop-rspec', '~> 2.31.0', require: false
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

gem 'propshaft'
gem 'importmap-rails'
gem "bootstrap", "~> 5.3"
# Use sqlite3 as the database for Active Record
gem 'sqlite3', '>= 1.4'
# Use the Puma web server [https://github.com/puma/puma]
gem 'puma', '>= 5.0'
# Bundle and process CSS [https://github.com/rails/cssbundling-rails]
gem 'cssbundling-rails'

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: %i[windows jruby]

gem "turbo-rails"
gem "stimulus-rails"
gem 'dotenv-rails'