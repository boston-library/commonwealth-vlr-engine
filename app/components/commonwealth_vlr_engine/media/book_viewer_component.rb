# frozen_string_literal: true

# wrapper for various media display components
module CommonwealthVlrEngine
  module Media
    class BookViewerComponent < ViewComponent::Base
      def initialize(document:, object_files:)
        @document = document
        @object_files = object_files
      end
      attr_reader :document, :object_files

      # TODO: DRY this out, also used in MultiImageViewerComponent
      IMAGE_VIEWER_LIMIT = 7

      def render?
        helpers.has_image_files?(object_files) && (helpers.has_searchable_text?(document) || object_files[:image].size > IMAGE_VIEWER_LIMIT)
      end
    end
  end
end
