# frozen_string_literal: true

module CommonwealthVlrEngine
  class BannerImageComponent < ViewComponent::Base
    include ApplicationHelper

    def initialize(context:, image_data:)
      @context = context
      @image_data = image_data
    end

    def banner_image_tag
      iiif_image_tag(@image_data.image_pid,
                     { size: @image_data.size, alt: @image_data.title, region: @image_data.region })
    end

    def banner_image_url
      solr_document_path(id: @image_data.object_pid)
    end

    def banner_image_title
      @image_data.title
    end
  end
end
