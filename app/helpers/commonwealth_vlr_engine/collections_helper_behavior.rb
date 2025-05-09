# frozen_string_literal: true

module CommonwealthVlrEngine
  module CollectionsHelperBehavior
    # link to view all items in a collection
    # @param document [SolrDocument] collection
    # @param class [String] CSS classes to add to the link
    def link_to_all_col_items(document, link_class: '')
      facet_params = { blacklight_config.collection_field => [document[blacklight_config.index.title_field.field]] }
      facet_params[blacklight_config.institution_field] = [document[blacklight_config.institution_field.to_sym]] if CommonwealthVlrEngine.config.dig(:institution, :pid).blank?
      search_params = { f: facet_params }
      search_params[:sort] = blacklight_config.date_asc_sort if document['destination_site_ssim'].to_s.include?('newspapers')
      link_to(t('blacklight.collections.browse.all'), search_catalog_path(search_params), class: link_class)
    end

    # DEPRECATED, moved to ImagesHelperBehavior
    # render the image and caption on collections#show page
    # depends on instance var set by CollectionsControllerBehavior:
    # @collection_image_info [Hash] = hash of relevant image parent item info
    # def render_collection_image(image_tag_class = nil)
    #   hosting_status = @collection_image_info&.dig(:hosting_status)
    #   image_url = collection_image_url(hosting_status: hosting_status)
    #   if @collection_image_info
    #     image_title = @collection_image_info[:title]
    #     render partial: 'collection_image',
    #            locals: { image_element: image_tag(image_url, alt: image_title, class: image_tag_class),
    #                      image_title: image_title, hosted: hosting_status == 'hosted' }
    #   else
    #     image_tag(image_url, alt: @collection_title, class: image_tag_class)
    #   end
    # end

    # DEPRECATED, MOVED TO ImagesHelperBehavior
    # IIIF URL for the image to be displayed on collections#show
    # preferred dimensions: 1100 width, 450 height
    # @param image_pid [String] Filestreams::Image ARK id
    # @param destination_site [Array]
    # @param target_width [Integer]
    # @param target_height [Integer]
    # @return [String]
    # def banner_image_iiif_url(image_pid, destination_site = %w(commonwealth), target_width = 1100, target_height = 450)
    #   image_info = get_image_metadata(image_pid)
    #   output_aspect = target_width.to_f / target_height.to_f
    #   if image_info[:aspect_ratio] > output_aspect
    #     top = 0
    #     height = image_info[:height]
    #     width = (height * output_aspect).round
    #   else
    #     width = (image_info[:width].to_f * 0.90).round # 90% so we don't get borders
    #     reduction_percent = (target_width.to_f / width.to_f).round(3)
    #     height = (target_height / reduction_percent).round
    #     # use the top section if this is a newspaper page, otherwise use the middle
    #     top = destination_site.include?('newspapers') ? 200 : (image_info[:height] - height) / 2
    #   end
    #   left = (image_info[:width] - width) / 2
    #   region = "#{left},#{top},#{width},#{height}"
    #   size_width = image_info[:width] < target_width ? image_info[:width] : target_width
    #   iiif_image_url(image_pid, { region: region, size: "#{size_width}," })
    # end

    def hosted_collection_class(document)
      harvested_object?(document) ? 'harvested-collection' : 'hosted-collection'
    end

    # whether the A-Z link menu should be displayed in collections#index
    # TODO: this isn't being used right now, remove? or use to to drive logic of AzLinksComponent#render?
    def should_render_col_az?
      false
    end
  end
end
