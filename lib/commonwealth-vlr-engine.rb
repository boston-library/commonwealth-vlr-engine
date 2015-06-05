require 'commonwealth-vlr-engine/engine'
require 'commonwealth-vlr-engine/version'

module CommonwealthVlrEngine

  require 'commonwealth-vlr-engine/controller_override'
  require 'commonwealth-vlr-engine/commonwealth_search_builder'
  require 'commonwealth-vlr-engine/controller'
  require 'commonwealth-vlr-engine/render_constraints_override'

  def self.inject!

    CatalogController.send(:include, CommonwealthVlrEngine::ControllerOverride)

    CatalogController.send(:include, CommonwealthVlrEngine::RenderConstraintsOverride)
    CatalogController.send(:helper, CommonwealthVlrEngine::RenderConstraintsOverride) unless
        CatalogController.helpers.is_a?(CommonwealthVlrEngine::RenderConstraintsOverride)
=begin
    # inject into SearchHistory and SavedSearches so spatial queries display properly
    SearchHistoryController.send(:helper, BlacklightMaps::RenderConstraintsOverride) unless
        SearchHistoryController.helpers.is_a?(BlacklightMaps::RenderConstraintsOverride)
    SavedSearchesController.send(:helper, BlacklightMaps::RenderConstraintsOverride) unless
        SavedSearchesController.helpers.is_a?(BlacklightMaps::RenderConstraintsOverride)
=end
  end

end

