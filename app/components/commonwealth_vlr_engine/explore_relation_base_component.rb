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

    # def link_to_all_featured_items(classes: '')
    #   facet_params = if context == 'institutions'
    #                    { helpers.blacklight_config.institution_field => [@institution_title || parent_document[helpers.blacklight_config.index.title_field]] }
    #                  else
    #                    { helpers.blacklight_config.institution_field => [parent_document[helpers.blacklight_config.institution_field]],
    #                      helpers.blacklight_config.collection_field => [parent_document[helpers.blacklight_config.index.title_field.field]] }
    #                  end
    #   link_to(I18n.t("blacklight.#{context}.browse.all"), search_catalog_path(f: facet_params), class: classes)
    # end

    def context
      parent_document.fetch(helpers.blacklight_config.index.display_type_field)&.downcase&.pluralize
    end

    def explore_image_tag
      image_tag(helpers.banner_image_url(exemplary_document: @explore_exemplary_document,
                                         target_height: 400,
                                         target_width: 550),
                alt: @explore_document[helpers.blacklight_config.index.title_field.field],
                class: 'explore-image')
    end

    def render?
      return unless explore_document.present?

      context == 'collection' && CommonwealthVlrEngine.config.dig(:institution, :pid).blank?
    end
  end
end
