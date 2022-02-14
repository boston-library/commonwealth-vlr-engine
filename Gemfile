source 'https://rubygems.org'

# Specify your gem's dependencies in commonwealth-vlr-engine.gemspec
gemspec

# If we don't specify 2.11.0 we'll end up with sprockets 2.12.0 in the main
# Gemfile.lock but since sass-rails gets generated (rails new) into the test app
# it'll want sprockets 2.11.0 and we'll have a conflict
gem 'sprockets', '2.11.0'

gem 'responders', "~> 2.0"
gem 'sass-rails', ">= 5.0"

group :test do
  gem 'simplecov', require: false
  gem 'coveralls', require: false
end

# file = File.expand_path("Gemfile", ENV['ENGINE_CART_DESTINATION'] || ENV['RAILS_ROOT'] || File.expand_path("../spec/internal", __FILE__))
# if File.exists?(file)
#   puts "Loading #{file} ..." if $DEBUG # `ruby -d` or `bundle -v`
#   instance_eval File.read(file)
# end
file = File.expand_path("Gemfile", ENV['ENGINE_CART_DESTINATION'] || ENV['RAILS_ROOT'] || File.expand_path(".internal_test_app", File.dirname(__FILE__)))
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
      ENV['ENGINE_CART_RAILS_OPTIONS']= "--edge --skip-turbolinks"
    else
      gem 'rails', ENV['RAILS_VERSION']
    end
  end

  if ENV['RAILS_VERSION'].nil? || ENV['RAILS_VERSION'] =~ /^5\.0/ || ENV['RAILS_VERSION'] == 'edge'
    # noop
  elsif ENV['RAILS_VERSION'] =~ /^4\.2/
    gem 'responders', "~> 2.0"
    gem 'sass-rails', ">= 5.0"
  else
    gem 'bootstrap-sass', '< 3.3.5' # 3.3.5 requires sass 3.3, incompatible with sass-rails 4.x
    gem 'sass-rails', "< 5.0"
  end
end