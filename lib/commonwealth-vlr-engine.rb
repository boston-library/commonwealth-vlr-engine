require 'commonwealth-vlr-engine/engine'
require 'commonwealth-vlr-engine/version'

module CommonwealthVlrEngine

  def self.inject!
=begin
    CatalogController.send(:include, BlacklightMaps::ControllerOverride)
    CatalogController.send(:include, BlacklightMaps::RenderConstraintsOverride)
    CatalogController.send(:helper, BlacklightMaps::RenderConstraintsOverride) unless
        CatalogController.helpers.is_a?(BlacklightMaps::RenderConstraintsOverride)

    # inject into SearchHistory and SavedSearches so spatial queries display properly
    SearchHistoryController.send(:helper, BlacklightMaps::RenderConstraintsOverride) unless
        SearchHistoryController.helpers.is_a?(BlacklightMaps::RenderConstraintsOverride)
    SavedSearchesController.send(:helper, BlacklightMaps::RenderConstraintsOverride) unless
        SavedSearchesController.helpers.is_a?(BlacklightMaps::RenderConstraintsOverride)
=end
  end

end

