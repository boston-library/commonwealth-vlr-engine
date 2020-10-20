# frozen_string_literal: true

# need to override some methods from BlacklightMaps
require Blacklight::Maps::Engine.root.join(CommonwealthVlrEngine::Engine.root,
                                           'config', 'initializers', 'patch_blacklight_maps')

class BlacklightMaps::GeojsonExport
  # LOCAL OVERRIDE - set partial to be rendered via options hash
  # TODO: submit a PR to allow/look for partial in options hash
  def render_leaflet_popup_content(geojson, hits = nil)
    partial = @options[:partial].presence
    if maps_config.search_mode == 'placename' &&
        geojson[:properties][maps_config.placename_property.to_sym]
      partial ||= 'catalog/map_placename_search'
      locals = { geojson_hash: geojson, hits: hits }
    else
      partial ||= 'catalog/map_spatial_search'
      locals = { coordinates: geojson[:bbox].presence || geojson[:geometry][:coordinates], hits: hits }
    end
    @controller.render_to_string(partial: partial, locals: locals)
  end
end
