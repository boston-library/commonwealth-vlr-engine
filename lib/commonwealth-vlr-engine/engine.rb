# frozen_string_literal: true

begin
  require 'blacklight'
  # require 'blacklight/gallery' # prob don't need this, we don't use any classes from this gem?
  require 'blacklight_advanced_search'
  # require 'blacklight/maps'
  require 'blacklight_range_limit'
  require 'blacklight_iiif_search'
  require 'typhoeus'
  require 'font-awesome-sass'
  # require 'unicode'
  require 'madison'
  require 'rsolr' unless defined? RSolr
  require 'iiif/presentation'
  require 'recaptcha'
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

    # as of sprockets >= 4 have to explicitly declare each file
    initializer 'commonwealth.assets.precompile' do |app|
      vlr_asset_base_path = File.join(CommonwealthVlrEngine.root, 'app', 'assets')
      vlr_assets = [
        Dir.glob(File.join(vlr_asset_base_path, 'images', 'commonwealth-vlr-engine', '*.{gif,png,svg}')),
        Dir.glob(File.join(vlr_asset_base_path, 'javascripts', 'commonwealth-vlr-engine', '*'))
      ]
      vlr_assets.each do |assets|
        assets.each do |asset|
          asset_filename = asset.split('/').last.gsub(/\.erb/, '')
          app.config.assets.precompile << "commonwealth-vlr-engine/#{asset_filename}"
        end
      end
      osd_images = Dir.glob(File.join(vlr_asset_base_path, 'images', 'commonwealth-vlr-engine', 'openseadragon', '*.png'))
      osd_images.each do |osd_img|
        app.config.assets.precompile << "commonwealth-vlr-engine/openseadragon/#{osd_img.split('/').last}"
      end
      app.config.assets.precompile << 'openseadragon.js'
    end
  end
end
