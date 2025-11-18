# frozen_string_literal: true

module CommonwealthVlrEngine
  module Media
    class ImageViewerComponent < ViewComponent::Base
      def initialize(document:, object_files:)
        @document = document
        @object_files = object_files
      end
      attr_reader :document, :object_files

      def image_key
        object_files[:image].first['storage_key_base_ss']
      end

      def image_ark_id
        image_key.split('/').last
      end

      def image_show_asset_url
        if document[helpers.blacklight_config.flagged_field.to_sym] != 'explicit'
          helpers.filestream_disseminator_url(image_key, 'image_access_800')
        else
          helpers.iiif_image_url(image_ark_id, { size: ',800' })
        end
      end

      def title_for_viewer_modal
        document[helpers.blacklight_config.index.title_field.field]&.html_safe&.delete("'")
      end

      def osd_tilesource
        CommonwealthVlrEngine.config[:iiif_server_url] + image_ark_id + '/info.json'
      end

      def render?
        helpers.has_image_files?(object_files) && object_files[:image].length == 1 && !helpers.has_searchable_text?(document)
      end
    end
  end
end
