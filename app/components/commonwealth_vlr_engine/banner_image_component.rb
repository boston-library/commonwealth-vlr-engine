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
      image_tag(helpers.banner_image_url(exemplary_document: @exemplary_document,
                                         target_width: width, target_height: height),
                alt: banner_image_title, class: banner_image_class)
    end

    def banner_image_title
      @exemplary_document[helpers.blacklight_config.index.title_field.field]
    end

    def banner_image_class
      "banner-image-#{@context}"
    end

    def hosted?
      @exemplary_document[helpers.blacklight_config.hosting_status_field] == 'hosted'
    end

    def render?
      @exemplary_document.present?
    end
  end
end
