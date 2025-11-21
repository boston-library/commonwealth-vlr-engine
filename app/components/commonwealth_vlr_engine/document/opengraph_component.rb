# frozen_string_literal: true

# facebook opengraph meta tags
module CommonwealthVlrEngine
  module Document
    class OpengraphComponent < ViewComponent::Base
      def initialize(document:, exemplary_document:, object_files:)
        @document = document
        @exemplary_document = exemplary_document
        @object_files = object_files
      end
      attr_reader :document, :exemplary_document, :object_files

      def og_url
        return helpers.show_solr_document_url(document, { controller: controller_name }) if controller_name == 'collections'

        return document[:identifier_uri_ss] if document[helpers.blacklight_config.hosting_status_field] == 'hosted'

        solr_document_url(document)
      end

      def og_title
        helpers.render_title(document)
      end

      def og_description
        helpers.truncate(document[:abstract_tsi], length: 300, separator: ' ', omission: '... ')
      end

      def og_image_url
        return helpers.banner_image_url(exemplary_document: exemplary_document) if controller_name == 'collections'

        return "#{document[:identifier_uri_ss]}/large_image" if helpers.has_image_files?(object_files)

        helpers.thumbnail_url(document)
      end

      def render_og_image?
        og_image_url.present?
      end

      def render?
        action_name == 'show' && %w(catalog collections).include?(controller_name)
      end
    end
  end
end
