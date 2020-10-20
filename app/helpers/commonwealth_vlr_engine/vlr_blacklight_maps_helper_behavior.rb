# frozen_string_literal: true

module CommonwealthVlrEngine
  module VlrBlacklightMapsHelperBehavior
    include Blacklight::BlacklightMapsHelperBehavior

    # OVERRIDE: convert state abbreviations, deal with complex locations, etc.
    # create a link to a location name facet value
    def link_to_placename_field(field_value, field, displayvalue = nil, catalogpath = nil)
      search_path = catalogpath || 'search_catalog_path'
      new_params = params.permit!
      field_values = field_value.split(', ')
      field_values = [field_values.join(', ')] if field_values.last.match?(/[\.\)]/) # Mass.)
      if field_values.length > 2
        new_field_values = []
        new_field_values[0] = field_value.split(/[,][ \w]*\z/).first
        new_field_values[1] = field_values.last
        field_values = new_field_values
      end
      if field_values.length == 2 && field_values.last.length == 2
        state_name = Madison.get_name(field_values.last)
        field_values[field_values.length - 1] = state_name if state_name
      end
      field_values.each do |val|
        # new_params = new_params.to_hash
        place = val.match?(/\(county\)/) ? val : val.gsub(/\s\([a-z]*\)\z/, '')
        unless params[:f] && params[:f][field] && params[:f][field].include?(place)
          # have to initialize SearchState with existing params as Hash, not HashWithIndifferentAccess
          new_params = Blacklight::SearchState.new(new_params.to_hash,
                                                   blacklight_config).add_facet_params(field, place)
        end
      end
      new_params[:view] = default_document_index_view_type
      link_to(displayvalue.presence || field_value,
              self.send(search_path, new_params.except(:id, :spatial_search_type, :coordinates)))
    end

    # return an array of Blacklight::SolrResponse::Facets::FacetItem items
    def map_facet_values
      map_facet_field = blacklight_config.view.maps.facet_mode == 'coordinates' ?
                            blacklight_config.view.maps.coordinates_facet_field :
                            blacklight_config.view.maps.geojson_field
      @response.aggregations[map_facet_field]&.items || []
    end

    # OVERRIDE: use a static file for catalog#map so page loads faster
    # render the map for #index and #map views
    def render_index_mapview
      static_geojson_file_loc = "#{Rails.root}/#{GEOJSON_STATIC_FILE['filepath']}"
      if Rails.env.to_s == 'production' && params[:action] == 'map' && File.exist?(static_geojson_file_loc)
        geojson_for_map = File.open(static_geojson_file_loc).first
      else
        geojson_for_map = serialize_geojson(map_facet_values)
      end
      render partial: 'catalog/index_mapview',
             locals: { geojson_features: geojson_for_map }
    end

    # OVERRIDE: allow controller.action name to be passed, allow @controller
    # pass the document or facet values to BlacklightMaps::GeojsonExport
    def serialize_geojson(documents, action_name = nil, options = {})
      action = action_name || controller.action_name
      cntrllr = @controller || controller
      export = BlacklightMaps::GeojsonExport.new(cntrllr, action.to_sym, documents, options)
      export.to_geojson
    end
  end
end
