# frozen_string_literal: true

module CommonwealthVlrEngine
  module InstitutionsHelperBehavior
    # link to view all items from an institution
    def link_to_all_inst_items(link_class)
      link_to(t('blacklight.institutions.browse.all'),
              search_catalog_path(f: { blacklight_config.institution_field => [@institution_title] }),
              class: link_class)
    end

    # render the institution description, truncating w/'more' link if more than 2 paragraphs
    # abstract = document[:abstract_tsi] field
    def render_institution_desc(abstract)
      desc_content = []
      # double quotes in #delete arg below are correct, DO NOT CHANGE
      abstract = abstract.delete("\n").delete("\r").gsub(/<br[ \/]*>/, '<br/>').split('<br/><br/>')
      desc_content << content_tag(:div,
                                  abstract[0..1].join('<br/><br/>').html_safe,
                                  id: 'institution_desc_static',
                                  class: 'institution_desc institution_desc_inline')
      if abstract.length > 2
        desc_content << content_tag(:div,
                                    abstract[2..(abstract.length - 1)].join('<br/><br/>').html_safe,
                                    id: 'institution_desc_collapse',
                                    class: 'collapse')
        desc_content << link_to(t('blacklight.institutions.description.more'),
                                '#institution_desc_collapse',
                                data: { bs_toggle: 'collapse', toggle_text: t('blacklight.institutions.description.less') },
                                aria: { expanded: 'false', controls: 'institution_desc_collapse' },
                                id: 'institution_desc_expand', class: 'toggle_text')
      end
      desc_content.join('').html_safe
    end

    # TODO: re-enable or remove once blacklight_maps re-integrated
    # replaces render_document_index in institutions/index partial
    # so we can use local index_map_institutions partial for map view
    # def render_institutions_index(documents = nil, locals = {})
    #   documents ||= @response.documents
    #   if document_index_view_type.to_s == 'maps'
    #     render partial: 'catalog/index_mapview_institutions',
    #            locals: { geojson_features: serialize_geojson(map_facet_values,
    #                                                          'index',
    #                                                          { partial: 'institutions/map_institutions_search' }) }
    #   else
    #     render_document_index_with_view(document_index_view_type, documents, locals)
    #   end
    # end

    # whether the A-Z link menu should be displayed in institutions#index
    # def should_render_inst_az?
    #   false
    # end
  end
end
