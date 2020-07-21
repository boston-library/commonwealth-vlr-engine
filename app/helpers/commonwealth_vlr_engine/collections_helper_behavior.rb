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

    # render the image and caption on collections#show page
    # depends on instance var set by CollectionsControllerBehavior:
    # @collection_image_info [Hash] = hash of relevant image parent item info
    def render_collection_image(image_tag_class = nil)
      if @collection_image_info
        image_title = @collection_image_info[:title]
        if @collection_image_info[:image_pid].match(/oai/) || @collection_image_info[:access_master] == false
          image_url = datastream_disseminator_url(@collection_image_info[:image_pid], 'thumbnail300')
        else
          image_url = collection_image_url(@collection_image_info[:image_pid])
        end
        render 'collection_image',
               {image_element: image_tag(image_url,
                                         :alt => image_title,
                                         :class => image_tag_class),
                image_title: image_title}
      else
        image_tag(collection_icon_path,
                  :alt => @collection_title,
                  :class => image_tag_class)
      end
    end

    # the IIIF URL for the image to be displayed on collections#show
    # if the image is too wide or narrow, return a square
    def collection_image_url(image_pid)
      image_info = get_image_metadata(image_pid)
      aspect = image_info[:aspect_ratio]
      region = (aspect > 1.67 || aspect < 0.33) ? 'square' : 'full'
      iiif_image_url(image_pid, {region: region, size: '600,'})
    end

    # whether the A-Z link menu should be displayed in collections#index
    def should_render_col_az?
      false
    end

  end
end