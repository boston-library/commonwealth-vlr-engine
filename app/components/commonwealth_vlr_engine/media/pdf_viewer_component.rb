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
        pdf_file = object_files[:document].find { |a| has_document_access_attachment?(a) }
        helpers.filestream_disseminator_url(pdf_file['storage_key_base_ss'], 'document_access')
      end

      def has_document_access_attachment?(solr_document)
        solr_document['attachments_ss']['document_access'].present?
      end

      def render?
        (helpers.has_document_files?(object_files) && object_files[:document].any? { |a| has_document_access_attachment?(a) }) &&
          !helpers.has_multiple_images?(object_files) && !helpers.has_playable_audio?(object_files)
      end
    end
  end
end
