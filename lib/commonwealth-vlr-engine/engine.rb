require 'blacklight'
require 'blacklight/gallery'
require 'blacklight_advanced_search'
require 'blacklight/maps'
require 'bpluser'
require 'typhoeus'
require 'devise'
require 'devise-guests'
require 'omniauth'
require 'omniauth-ldap'
require 'omniauth-facebook'
require 'omniauth-polaris'
require 'bootstrap-sass'
require 'font-awesome-sass'
require 'unicode'
require 'madison'

module CommonwealthVlrEngine

  class Engine < Rails::Engine

    # for db migrations
    engine_name 'commonwealth_vlr_engine'

    config.to_prepare do
      CommonwealthVlrEngine.inject!
    end

    # This makes our rake tasks visible.
    rake_tasks do
      Dir.chdir(File.expand_path(File.join(File.dirname(__FILE__), '..', '..'))) do
        Dir.glob(File.join('tasks', '*.rake')).each do |railtie|
          load railtie
        end
      end
      #load "#{config.root}/tasks/dc_public.rake"
    end
  end
end
