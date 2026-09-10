# frozen_string_literal: true

module CommonwealthVlrEngine
  class BannerImageComponent < ViewComponent::Base
    # @param exemplary_document [SolrDocument] DigitalObject solr document
    # @param context [String] the type of page where the banner is being rendered
    def initialize(exemplary_document:, width: 1300, height: 610, context: 'collection')
      @exemplary_document = exemplary_document
      @width = width
      @height = height
      @context = context
    end

    def banner_image_tag
      image_url = if @exemplary_document
                    helpers.banner_image_url(exemplary_document: @exemplary_document,
                                             target_width: @width, target_height: @height)
                  else
                    helpers.asset_url("commonwealth-vlr-engine/dc_#{@context}-icon.png")
                  end
      image_tag(image_url, alt: banner_image_title, class: banner_image_class)
    end

    def banner_image_title
      @exemplary_document.present? ? helpers.render_title(@exemplary_document) : "#{@context} icon"
    end

    def banner_image_link
      return banner_image_tag unless @exemplary_document

      link_to banner_image_tag, solr_document_path(@exemplary_document['id']),
              id: 'banner_image', class: "#{banner_image_class}-link"
    end

    def banner_image_class
      "banner-image-#{@context}"
    end

    def render_image_title?
      return unless @exemplary_document

      @exemplary_document[helpers.blacklight_config.hosting_status_field] == 'hosted' &&
        @exemplary_document[:identifier_iiif_manifest_ss].present?
    end
  end
end
