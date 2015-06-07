require 'hydra/head'
require 'blacklight/gallery'
require 'blacklight'

module CommonwealthVlrEngine
  extend ActiveSupport::Autoload

  class Engine < Rails::Engine

    # Set some default configurations
    #Blacklight::Configuration.default_values[:view].maps.geojson_field = "geojson"

    # Add our helpers
    #initializer 'commonwealth-vlr-engine.helpers' do |app|
    #  ActionView::Base.send :include, BlacklightMapsHelper
    #end

    config.autoload_paths += %W(
     #{config.root}/app/controllers
      #{config.root}/app/models
      #{Hydra::Engine.root}/app/models/concerns
    )

    config.to_prepare do
      CommonwealthVlrEngine.inject!
    end

    # This makes our rake tasks visible.
    rake_tasks do
      Dir.chdir(File.expand_path(File.join(File.dirname(__FILE__), '..', '..'))) do
        Dir.glob(File.join('railties', '*.rake')).each do |railtie|
          load railtie
        end
      end
    end
  end
end
