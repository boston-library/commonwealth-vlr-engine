require 'blacklight'

module CommonwealthVlrEngine
  class Engine < Rails::Engine

    # Set some default configurations
    #Blacklight::Configuration.default_values[:view].maps.geojson_field = "geojson"

    # Add our helpers
    #initializer 'commonwealth-vlr-engine.helpers' do |app|
    #  ActionView::Base.send :include, BlacklightMapsHelper
    #end

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
