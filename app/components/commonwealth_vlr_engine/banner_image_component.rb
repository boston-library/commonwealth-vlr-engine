# frozen_string_literal: true

module CommonwealthVlrEngine
  class BannerImageComponent < ViewComponent::Base
    # include ApplicationHelper # shouldn't need this, use helpers.helper_method instead

    def initialize(context:, image_data:)
      @context = context
      @image_data = image_data
    end

    def banner_image_tag
      helpers.iiif_image_tag(@image_data.image_pid,
                             { size: @image_data.size, region: @image_data.region,
                               alt: banner_image_title })
    end

    def banner_image_url
      solr_document_path(id: @image_data.object_pid)
    end

    def banner_image_title
      @image_data.title
    end

    def banner_image_class

    end

    def banner_image_caption

    end
  end
end
