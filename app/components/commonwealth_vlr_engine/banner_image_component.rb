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

    # def icon_url(context: 'collection')
    #   helpers.asset_url("commonwealth-vlr-engine/dc_#{context}-icon.png")
    # end

    def banner_image_title
      @exemplary_document[helpers.blacklight_config.index.title_field.field]
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

    def render?
      @exemplary_document.present?
    end
  end
end
