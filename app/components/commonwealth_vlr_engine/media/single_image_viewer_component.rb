# frozen_string_literal: true

module CommonwealthVlrEngine
  module Media
    class SingleImageViewerComponent < ViewComponent::Base
      def initialize(document:, object_files:)
        @document = document
        @object_files = object_files
      end
      attr_reader :document, :object_files

      def image_key
        object_files[:image].first['storage_key_base_ss']
      end

      def title_for_viewer_modal
        document[helpers.blacklight_config.index.title_field.field]&.html_safe&.gsub(/\'/,'')
      end

      def osd_tilesource
        CommonwealthVlrEngine.config[:iiif_server_url] + image_key.split('/').last + '/info.json'
      end

      def render?
        helpers.has_image_files?(object_files) && object_files[:image].length == 1 && !helpers.has_searchable_text?(document)
      end
    end
  end
end
