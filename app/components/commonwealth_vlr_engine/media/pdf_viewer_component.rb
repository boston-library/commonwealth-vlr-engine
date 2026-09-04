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

      PDF_VIEWER_IGNORE_GENRES = ['Books', 'Correspondence', 'Ephemera', 'Manuscripts',
                                  'Musical notation', 'Newspapers', 'Periodicals', 'Prints'].freeze

      def pdf_urls_for_viewer
        document_files = object_files[:audio] + object_files[:video] + object_files[:document]
        pdf_files = document_files.select { |a| helpers.has_attachment?(a, 'document_access') }
        pdf_files.map { |pdf_file| helpers.filestream_disseminator_url(pdf_file['storage_key_base_ss'], 'document_access') }
      end

      # logic for whether PDF viewer should be displayed (IT'S COMPLICATED):
      #  - item has no images, audio, or video
      #  - item has images, and is not a book, newspaper, manuscript, periodical, etc.
      #  - item has images, and is a document, and does not have downloadable PDF
      #  - item has audio/video, but PDF is not downloadable
      def render?
        return unless helpers.has_pdf_files?(object_files)

        return if helpers.include_uv?(document, object_files)

        document_genres = document[:genre_basic_ssim] || []
        return if helpers.has_image_files?(object_files) && PDF_VIEWER_IGNORE_GENRES.any? { |g| document_genres.include?(g) }

        if helpers.has_downloadable_files?(document, object_files)
          return if helpers.has_image_files?(object_files) && document_genres.include?('Documents')

          return if helpers.has_playable_audio?(object_files) || helpers.has_video_files?(object_files)
        end

        true
      end
    end
  end
end
