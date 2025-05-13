# frozen_string_literal: true

# render a component for #show views to include information about an institution or collection
module CommonwealthVlrEngine
  class ExploreRelationBaseComponent < ViewComponent::Base
    attr_reader :explore_document, :explore_exemplary_document, :parent_document

    # @param [SolrDocument] explore_document, explore_exemplary_document, parent_document
    def initialize(explore_document:, explore_exemplary_document:, parent_document:)
      @explore_document = explore_document
      @explore_exemplary_document = explore_exemplary_document
      @parent_document = parent_document
    end

    def context
      parent_document.fetch(helpers.blacklight_config.index.display_type_field)&.downcase&.pluralize
    end

    def explore_image_tag
      image_tag(helpers.banner_image_url(exemplary_document: explore_exemplary_document,
                                         target_height: 400,
                                         target_width: 550),
                alt: explore_document[helpers.blacklight_config.index.title_field.field],
                class: 'explore-image')
    end

    def explore_link
      link_to(explore_document[helpers.blacklight_config.index.title_field.field],
              helpers.public_send(explore_path, id: parent_document[:id]), id: 'explore_link')
    end

    def explore_text
      helpers.index_abstract({ value: [explore_document['abstract_tsi']], document: explore_document,
                               path_helper: explore_path, truncate_length: 600 })
    end

    def explore_path
      context == 'digitalobjects' ? :collection_path : :institution_path
    end

    def render?
      return if explore_document.blank?

      context == 'collections' && CommonwealthVlrEngine.config.dig(:institution, :pid).blank?
    end
  end
end
