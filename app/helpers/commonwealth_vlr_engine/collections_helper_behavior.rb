# frozen_string_literal: true

module CommonwealthVlrEngine
  module CollectionsHelperBehavior
    # link to view all items in a collection
    def link_to_all_col_items(col_title, institution_name = nil, link_class)
      facet_params = { blacklight_config.collection_field => [col_title] }
      facet_params[blacklight_config.institution_field] = [institution_name] if institution_name
      link_to(t('blacklight.collections.browse.all'),
              search_catalog_path(f: facet_params),
              class: link_class)
    end

    # render the image and caption on collections#show page
    # depends on instance var set by CollectionsControllerBehavior:
    # @collection_image_info [Hash] = hash of relevant image parent item info
    def render_collection_image(image_tag_class = nil)
      if @collection_image_info
        image_title = @collection_image_info[:title]
        hosted = @collection_image_info[:hosting_status] == 'hosted' ? true : false
        if !hosted || @collection_image_info[:access_master] == false
          image_url = filestream_disseminator_url(@collection_image_info[:image_key], 'image_thumbnail_300')
        else
          image_url = collection_image_url(@collection_image_info[:image_pid],
                                           @collection_image_info[:destination_site])
        end
        render partial: 'collection_image',
               locals: { image_element: image_tag(image_url, alt: image_title, class: image_tag_class),
                         image_title: image_title, hosted: hosted }
      else
        image_tag(collection_icon_path, alt: @collection_title, class: image_tag_class)
      end
    end

    # IIIF URL for the image to be displayed on collections#show
    # preferred dimensions: 1100 width, 450 height
    # @param image_pid [String] Filestreams::Image ARK id
    # @param destination_site [Array]
    # @param target_width [Integer]
    # @param target_height [Integer]
    # @return [String]
    def collection_image_url(image_pid, destination_site = %w(commonwealth), target_width = 1100, target_height = 450)
      image_info = get_image_metadata(image_pid)
      output_aspect = target_width.to_f / target_height.to_f
      if image_info[:aspect_ratio] > output_aspect
        top = 0
        height = image_info[:height]
        width = (height * output_aspect).round
      else
        width = (image_info[:width].to_f * 0.90).round # 90% so we don't get borders
        reduction_percent = (target_width.to_f / width.to_f).round(3)
        height = (target_height / reduction_percent).round
        # use the top section if this is a newspaper page, otherwise use the middle
        top = destination_site.include?('newspapers') ? 200 : (image_info[:height] - height) / 2
      end
      left = (image_info[:width] - width) / 2
      region = "#{left},#{top},#{width},#{height}"
      size_width = image_info[:width] < target_width ? image_info[:width] : target_width
      iiif_image_url(image_pid, { region: region, size: "#{size_width}," })
    end

    def hosted_collection_class(document)
      document[blacklight_config.hosting_status_field.to_sym] == 'harvested' ? 'harvested-collection' : 'hosted-collection'
    end

    # whether the A-Z link menu should be displayed in collections#index
    def should_render_col_az?
      false
    end
  end
end
