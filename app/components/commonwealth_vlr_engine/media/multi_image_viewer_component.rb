# frozen_string_literal: true

module CommonwealthVlrEngine
  module Media
    class MultiImageViewerComponent < ViewComponent::Base
      def initialize(document:, object_files:)
        @document = document
        @object_files = object_files
      end
      attr_reader :document, :object_files

      IMAGE_VIEWER_LIMIT = 7

      def image_keys
        object_files[:image].map { |i| i['storage_key_base_ss'] }
      end

      def osd_tilesources
        image_keys.map do |ik|
          CommonwealthVlrEngine.config[:iiif_server_url] + ik.split('/').last + '/info.json'
        end.to_json
      end

      def render?
        helpers.has_multiple_images?(object_files) && object_files[:image].length <= IMAGE_VIEWER_LIMIT && !helpers.has_searchable_text?(document)
      end
    end
  end
end
