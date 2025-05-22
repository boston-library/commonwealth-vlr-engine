# frozen_string_literal: true

# wrapper for various media display components
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

      def render?
        helpers.has_image_files?(object_files) && object_files[:image].length == 1 && !helpers.has_searchable_text?(document)
      end
    end
  end
end
