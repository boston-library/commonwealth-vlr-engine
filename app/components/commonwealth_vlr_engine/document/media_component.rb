# frozen_string_literal: true

# wrapper for various media display components
module CommonwealthVlrEngine
  module Document
    class MediaComponent < ViewComponent::Base
      def initialize(document:, object_files:)
        @document = document
        @object_files = object_files
      end
      attr_reader :document, :object_files

      IMAGE_VIEWER_LIMIT = 7

      def single_image_viewer
        render CommonwealthVlrEngine::Media::SingleImageViewerComponent.new(document: document, object_files: object_files)
      end

      # def has_image_files?
      #   object_files[:image].present?
      # end
      #
      # def has_multiple_images?
      #   has_image_files? && object_files[:image].size > 1
      # end
      #
      # def has_video_files?
      #   object_files[:video].present?
      # end
      #
      # def has_audio_files?
      #   object_files[:audio].present?
      # end
      #
      # def has_document_files?
      #   object_files[:document].present?
      # end
      #
      # def has_ereader_files?
      #   object_files[:ereader].present?
      # end
      #
      # def has_playable_audio?
      #   has_audio_files? && object_files[:audio].all? { |a| a['attachments_ss']['audio_access'].present? }
      # end
      #
      # def has_pdf_files?
      #   has_document_files? && object_files[:document].any? { |a| a['attachments_ss']['document_access'].present? }
      # end
      #
      # def book_reader?
      #   has_image_files? && (helpers.has_searchable_text?(document) || object_files[:image].size > IMAGE_VIEWER_LIMIT)
      # end

      def render?
        puts "OBJECT_FILES (MEDCOM) = #{object_files}"
        true # logic TK
      end
    end
  end
end
