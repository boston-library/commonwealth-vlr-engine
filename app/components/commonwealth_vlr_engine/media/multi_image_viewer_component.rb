# frozen_string_literal: true

module CommonwealthVlrEngine
  module Media
    class MultiImageViewerComponent < CommonwealthVlrEngine::Document::MediaComponent
      def image_keys
        object_files[:image].map { |i| i['storage_key_base_ss'] }
      end

      def osd_tilesources
        image_keys.map do |ik|
          CommonwealthVlrEngine.config[:iiif_server_url] + ik.split('/').last + '/info.json'
        end.to_json
      end

      def render?
        helpers.has_multiple_images?(object_files) &&
          object_files[:image].length <= CommonwealthVlrEngine::Document::MediaComponent::IMAGE_VIEWER_LIMIT &&
          !helpers.has_searchable_text?(document)
      end
    end
  end
end
