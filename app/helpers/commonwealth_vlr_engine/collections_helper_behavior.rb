module CommonwealthVlrEngine
  module CollectionsHelperBehavior

    # link to view all items in a collection
    def link_to_all_col_items(col_title, institution_name=nil, link_class)
      facet_params = {blacklight_config.collection_field => [col_title]}
      facet_params[blacklight_config.institution_field] = institution_name if institution_name
      link_to(t('blacklight.collections.browse.all'),
              search_catalog_path(:f => facet_params),
              :class => link_class)
    end

    # whether the A-Z link menu should be displayed in collections#index
    def should_render_col_az?
      false
    end

  end
end