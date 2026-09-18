# frozen_string_literal: true

module CommonwealthVlrEngine
  module Media
    class AudioPlayerComponent < CommonwealthVlrEngine::Document::MediaComponent
      def audio_files
        object_files[:audio]
      end

      def audio_title
        (audio_files.length > 1 ? '1. ' : '') + audio_files.first['filename_base_ssi']
      end

      def render?
        helpers.has_playable_audio?(object_files)
      end
    end
  end
end
