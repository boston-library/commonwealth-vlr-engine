# frozen_string_literal: true

require 'commonwealth-vlr-engine/engine'
require 'commonwealth-vlr-engine/version'

module CommonwealthVlrEngine
  require 'commonwealth-vlr-engine/controller_override'
  require 'commonwealth-vlr-engine/search_builder/search_builder_behavior'
  require 'commonwealth-vlr-engine/search_builder/institutions_search_builder'
  require 'commonwealth-vlr-engine/search_builder/collections_search_builder'
  require 'commonwealth-vlr-engine/search_builder/flagged_search_builder'
  require 'commonwealth-vlr-engine/search_builder/ocr_search_builder'
  require 'commonwealth-vlr-engine/search_builder/mlt_search_builder'
  require 'commonwealth-vlr-engine/controller'
  require 'commonwealth-vlr-engine/finder'
  require 'commonwealth-vlr-engine/notifier'
  require 'commonwealth-vlr-engine/iiif_manifest'
  require 'commonwealth-vlr-engine/search_state'
  require 'commonwealth-vlr-engine/streaming'

  def self.config
    @config ||= YAML.safe_load(ERB.new(File.read(config_path)).result, aliases: true)[env].with_indifferent_access
  end

  def self.root
    @root ||= File.expand_path(File.dirname(File.dirname(__FILE__)))
  end

  def self.app_root
    return @app_root if @app_root

    @app_root = Rails.root if defined?(Rails) and defined?(Rails.root)
    @app_root ||= APP_ROOT if defined?(APP_ROOT)
    @app_root ||= '.'
  end

  def self.env
    return @env if @env

    @env ||= Rails.env if defined?(Rails) and defined?(Rails.root)
    @env ||= 'development'
  end

  def self.config_path
    File.join(app_root, 'config', 'vlr.yml')
  end
end
