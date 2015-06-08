# need to override some methods from BlacklightMaps

require Blacklight::Maps::Engine.root.join(CommonwealthVlrEngine::Engine.root, 'config','initializers','patch_blacklight_maps')

class BlacklightMaps::GeojsonExport

  # LOCAL OVERRIDE - set partial to be rendered via options hash
  def render_leaflet_popup_content(geojson_hash, hits=nil)
    partial_to_render = @options[:partial].presence
    if search_mode == 'placename' && geojson_hash[:properties][placename_property.to_sym]
      @controller.render_to_string partial: partial_to_render || 'catalog/map_placename_search',
                                   locals: { geojson_hash: geojson_hash, hits: hits }
    else
      @controller.render_to_string partial: partial_to_render || 'catalog/map_spatial_search',
                                   locals: { coordinates: geojson_hash[:bbox].presence || geojson_hash[:geometry][:coordinates],
                                             hits: hits }
    end
  end

end