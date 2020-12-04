# frozen_string_literal: true

source 'https://rubygems.org'

git_source(:github) { |repo| "https://github.com/boston-library/#{repo}.git" }

# Specify your gem's dependencies in commonwealth-vlr-engine.gemspec
gemspec

group :development, :test do
  gem 'rubocop', '~> 0.75.1', require: false
  gem 'rubocop-performance', '~> 1.5', require: false
  gem 'rubocop-rails', '~> 2.4.2', require: false
  gem 'rubocop-rspec', require: false
end

group :test do
  gem 'coveralls', require: false
  gem 'database_cleaner'
  gem 'puffing-billy'
  gem 'rails-controller-testing'
  gem 'vcr', '~> 6.0'
  gem 'webdrivers', '~> 3.0'
  gem 'webmock', '~> 3.8'
end
# BEGIN ENGINE_CART BLOCK
# engine_cart: 2.3.0
# engine_cart stanza: 0.10.0

# the below comes from engine_cart, a gem used to test this Rails engine gem in the context of a Rails app.
file = File.expand_path('Gemfile', ENV['ENGINE_CART_DESTINATION'] || ENV['RAILS_ROOT'] || File.expand_path('.internal_test_app', File.dirname(__FILE__)))
if File.exist?(file)
  begin
    eval_gemfile file
  rescue Bundler::GemfileError => e
    Bundler.ui.warn '[EngineCart] Skipping Rails application dependencies:'
    Bundler.ui.warn e.message
  end
else
  Bundler.ui.warn "[EngineCart] Unable to find test application dependencies in #{file}, using placeholder dependencies"

  if ENV['RAILS_VERSION']
    if ENV['RAILS_VERSION'] == 'edge'
      gem 'rails', github: 'rails/rails'
      ENV['ENGINE_CART_RAILS_OPTIONS'] = '--edge --skip-turbolinks'
    else
      gem 'rails', ENV['RAILS_VERSION']
    end
  end

  case ENV['RAILS_VERSION']
  when /^5.[12]/, /^6.0/
    gem 'sass-rails', '~> 5.0'
  when /^4.2/
    gem 'responders', '~> 2.0'
    gem 'sass-rails', '>= 5.0'
    gem 'coffee-rails', '~> 4.1.0'
    gem 'json', '~> 1.8'
  when /^4.[01]/
    gem 'sass-rails', '< 5.0'
  end
end
# END ENGINE_CART BLOCK

eval_gemfile File.expand_path("spec/test_app_templates/Gemfile.extra", File.dirname(__FILE__))
