# frozen_string_literal: true

# wrapper for various media display components
module CommonwealthVlrEngine
  module Media
    class PdfViewerComponent < ViewComponent::Base
      def initialize(document:, object_files:)
        @document = document
        @object_files = object_files
      end
      attr_reader :document, :object_files

      def pdf_url_for_viewer
        pdf_file = object_files[:document].find { |a| helpers.has_attachment?(a, 'document_access') }
        helpers.filestream_disseminator_url(pdf_file['storage_key_base_ss'], 'document_access')
      end

      def render?
        helpers.has_pdf_files?(object_files) && !helpers.has_multiple_images?(object_files) &&
          !helpers.has_playable_audio?(object_files) && !helpers.has_video_files?(object_files)
      end
    end
  end
end
