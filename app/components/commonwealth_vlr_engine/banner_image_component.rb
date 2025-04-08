# frozen_string_literal: true

module CommonwealthVlrEngine
  class BannerImageComponent < ViewComponent::Base
    def initialize(exemplary_document:, context: 'collection', iiif_image_data: {})
      @exemplary_document = exemplary_document
      @context = context
      @iiif_image_data = iiif_image_data
    end

    def banner_image_tag
      image_tag(helpers.banner_image_url(exemplary_document: @exemplary_document),
                alt: banner_image_title, class: banner_image_class)
    end

    # @deprecated, moved to ImagesHelperBehavior
    # def banner_image_url
    #   if @exemplary_document
    #     if !hosted? || !iiif_image?
    #       helpers.filestream_disseminator_url(@exemplary_document[:exemplary_image_key_base_ss], 'image_thumbnail_300')
    #     else
    #       banner_image_iiif_url(image_ark_id: @exemplary_document[:exemplary_image_ssi],
    #                             destination_site: @exemplary_document[:destination_site_ssim])
    #     end
    #   else
    #     icon_url(context: @context)
    #   end
    # end

    def icon_url(context: 'collection')
      helpers.asset_url("commonwealth-vlr-engine/dc_#{context}-icon.png")
    end

    # @deprecated, moved to ImagesHelperBehavior
    # def banner_image_iiif_url(image_ark_id:, destination_site: %w(commonwealth), target_width: 1100, target_height: 450)
    #   image_info = helpers.get_image_metadata(image_ark_id)
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
    #   helpers.iiif_image_url(image_ark_id, { region: region, size: "#{size_width}," })
    # end

    def banner_image_title
      @exemplary_document[helpers.blacklight_config.index.title_field]
    end

    def banner_image_class
      "banner-image-#{@context}"
    end

    def hosted?
      @exemplary_document[helpers.blacklight_config.hosting_status_field] == 'hosted'
    end

    def iiif_image?
      @exemplary_document['identifier_iiif_manifest_ss'].present?
    end
  end
end
