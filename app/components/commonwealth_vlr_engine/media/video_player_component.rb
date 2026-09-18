# frozen_string_literal: true

module CommonwealthVlrEngine
  module Media
    class VideoPlayerComponent < CommonwealthVlrEngine::Document::MediaComponent
      def video_key
        object_files[:video][0]['storage_key_base_ss']
      end

      def render?
        helpers.has_video_files?(object_files)
      end
    end
  end
end
