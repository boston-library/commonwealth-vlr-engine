# frozen_string_literal: true

# wrapper for various media display components
module CommonwealthVlrEngine
  module Media
    class AudioPlayerComponent < ViewComponent::Base
      def initialize(document:, object_files:)
        @document = document
        @object_files = object_files
      end
      attr_reader :document, :object_files

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
