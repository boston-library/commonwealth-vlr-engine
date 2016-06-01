require 'commonwealth-vlr-engine/engine'
require 'commonwealth-vlr-engine/version'

module CommonwealthVlrEngine

  require 'commonwealth-vlr-engine/controller_override'
  require 'commonwealth-vlr-engine/search_builder/commonwealth_search_builder_behavior'
  require 'commonwealth-vlr-engine/search_builder/institutions_search_builder'
  require 'commonwealth-vlr-engine/search_builder/collections_search_builder'
  require 'commonwealth-vlr-engine/search_builder/flagged_search_builder'
  require 'commonwealth-vlr-engine/search_builder/ocr_search_builder'
  #require 'commonwealth-vlr-engine/commonwealth_search_builder'
  require 'commonwealth-vlr-engine/controller'
  require 'commonwealth-vlr-engine/render_constraints_override'
  require 'commonwealth-vlr-engine/pages'
  #require 'commonwealth-vlr-engine/routes'
  #require 'commonwealth-vlr-engine/route_sets'
  require 'commonwealth-vlr-engine/finder'
  require 'commonwealth-vlr-engine/notifier'
  require 'commonwealth-vlr-engine/iiif_manifest'

  def self.config
    @config ||= YAML::load(File.open(config_path))[env]
    .with_indifferent_access
  end

  def self.app_root
    return @app_root if @app_root
    @app_root = Rails.root if defined?(Rails) and defined?(Rails.root)
    @app_root ||= APP_ROOT if defined?(APP_ROOT)
    @app_root ||= '.'
  end

  def self.env
    return @env if @env
    #The following commented line always returns "test" in a rails c production console. Unsure of how to fix this yet...
    #@env = ENV["RAILS_ENV"] = "test" if ENV
    @env ||= Rails.env if defined?(Rails) and defined?(Rails.root)
    @env ||= 'development'
  end

  def self.config_path
    File.join(app_root, 'config', 'vlr.yml')
  end
=begin
  def self.inject!

    CatalogController.send(:include, CommonwealthVlrEngine::RenderConstraintsOverride)
    CatalogController.send(:helper, CommonwealthVlrEngine::RenderConstraintsOverride) unless
        CatalogController.helpers.is_a?(CommonwealthVlrEngine::RenderConstraintsOverride)

    # inject into SearchHistory and SavedSearches so mlt queries display properly
    SearchHistoryController.send(:helper, CommonwealthVlrEngine::RenderConstraintsOverride) unless
        SearchHistoryController.helpers.is_a?(CommonwealthVlrEngine::RenderConstraintsOverride)
    SavedSearchesController.send(:helper, CommonwealthVlrEngine::RenderConstraintsOverride) unless
        SavedSearchesController.helpers.is_a?(CommonwealthVlrEngine::RenderConstraintsOverride)
  end
=end
end

