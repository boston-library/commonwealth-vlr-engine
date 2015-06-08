module CommonwealthVlrEngine
  module BlacklightMapsHelper
    include Blacklight::BlacklightMapsHelperBehavior

    # LOCAL OVERRIDE: convert state abbreviations, deal with complex locations, etc.
    # create a link to a location name facet value
    def link_to_placename_field field_value, field, displayvalue = nil, catalogpath = nil
      search_path = catalogpath || 'catalog_index_path'
      new_params = params
      new_params[:view] = default_document_index_view_type
      field_values = field_value.split(', ')
      if field_values.last.match(/[\.\)]/) # Mass.)
        field_values = [field_values.join(', ')]
      end
      if field_values.length > 2
        new_field_values = []
        new_field_values[0] = field_value.split(/[,][ \w]*\z/).first
        new_field_values[1] = field_values.last
        field_values = new_field_values
      end
      if field_values.length == 2 && field_values.last.length == 2
        state_name = Bplmodels::Constants::STATE_ABBR[field_values.last]
        field_values[field_values.length-1] = state_name if state_name
      end
      field_values.each do |val|
        place = val.match(/\(county\)/) ? val : val.gsub(/\s\([a-z]*\)\z/,'')
        new_params = add_facet_params(field, place, new_params) unless params[:f] && params[:f][field] && params[:f][field].include?(place)
        new_params[:view] = default_document_index_view_type
      end
      link_to(displayvalue.presence || field_value,
              self.send(search_path,new_params.except(:id, :spatial_search_type, :coordinates)))
    end


    # LOCAL OVERRIDE: allow controller.action name to be passed, allow @controller
    # pass the document or facet values to BlacklightMaps::GeojsonExport
    def serialize_geojson(documents, action_name=nil, options={})
      action = action_name || controller.action_name
      cntrllr = @controller || controller
      export = BlacklightMaps::GeojsonExport.new(cntrllr, action, documents, options)
      export.to_geojson
    end

  end

end