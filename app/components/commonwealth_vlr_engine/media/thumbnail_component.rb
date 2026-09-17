# frozen_string_literal: true

# render a thumbnail if no other displayable media exists
module CommonwealthVlrEngine
  module Media
    class ThumbnailComponent < ViewComponent::Base
      def initialize(document:, object_files:)
        @document = document
        @object_files = object_files
      end
      attr_reader :document, :object_files

      def render?
        !helpers.has_image_files?(object_files) && !helpers.has_playable_audio?(object_files) &&
          !helpers.has_video_files?(object_files) && !helpers.has_pdf_files?(object_files)
      end
    end
  end
end
