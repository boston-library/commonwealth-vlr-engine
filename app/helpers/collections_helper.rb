module CollectionsHelper

  # link to view all items in a collection
  def link_to_all_col_items(col_title, institution_name=nil, link_class)
    facet_params = {blacklight_config.collection_field => [col_title]}
    facet_params[blacklight_config.institution_field] = institution_name if institution_name
    link_to(t('blacklight.collections.browse.all'),
            catalog_index_path(:f => facet_params),
            :class => link_class)
  end

  # link to collections starting with a specific letter
  def link_to_cols_start_with(letter)
    link_to(letter,
            collections_path(:q => 'title_info_primary_ssort:' + letter + '*'),
            :class => 'col_a-z_link'
    )
  end

end