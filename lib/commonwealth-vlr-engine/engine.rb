# frozen_string_literal: true

begin
  require 'blacklight'
  require 'blacklight/gallery'
  require 'blacklight_advanced_search'
  require 'blacklight_range_limit'
  require 'blacklight_iiif_search'
  require 'typhoeus'
  require 'font-awesome-sass'
  require 'htmlentities'
  require 'madison'
  require 'openseadragon'
  require 'rsolr' unless defined? RSolr
  require 'iiif/presentation'
  require 'recaptcha'
  require 'rexml'
  require 'zipline'
rescue LoadError => e
  puts "A Gem Dependency is Missing....#{e.message}"
end

module CommonwealthVlrEngine
  class Engine < Rails::Engine
    # for db migrations
    engine_name 'commonwealth_vlr_engine'

    # This makes our rake tasks visible.
    rake_tasks do
      Dir.chdir(File.expand_path(File.join(File.dirname(__FILE__), '..', '..'))) do
        Dir.glob(File.join('tasks', '*.rake')).each do |railtie|
          load railtie
        end
        Dir.glob(File.join('lib/railties', '*.rake')).each do |railtie|
          load railtie
        end
      end
    end

    initializer 'commonwealth_vlr_engine.importmap', before: 'importmap' do |app|
      app.config.assets.paths << Engine.root.join('app/javascript')
      app.config.importmap.paths << Engine.root.join('config/importmap.rb')
      app.config.importmap.cache_sweepers << Engine.root.join('app/javascript')
    end
  end
end
