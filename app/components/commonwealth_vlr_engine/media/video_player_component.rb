# frozen_string_literal: true

# wrapper for various media display components
module CommonwealthVlrEngine
  module Media
    class VideoPlayerComponent < ViewComponent::Base
      def initialize(document:, object_files:)
        @document = document
        @object_files = object_files
      end
      attr_reader :document, :object_files

      def video_key
        object_files[:video][0]['storage_key_base_ss']
      end

      def render?
        helpers.has_video_files?(object_files)
      end
    end
  end
end
