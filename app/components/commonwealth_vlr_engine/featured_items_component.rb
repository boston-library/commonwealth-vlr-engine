# frozen_string_literal: true

module CommonwealthVlrEngine
  class FeaturedItemsComponent < ViewComponent::Base
    attr_reader :featured_documents, :parent_document

    def initialize(featured_documents: [], parent_document: nil)
      @featured_documents = featured_documents
      @parent_document = parent_document
    end

    def view_config
      helpers.blacklight_config&.view_config(:masonry)
    end

    def featured_documents_presenters
      featured_documents.map { |doc| CommonwealthVlrEngine::IndexPresenter.new(doc, controller.view_context) }
    end

    def link_to_all_featured_items(classes: '')
      facet_params = if context == 'institutions'
                       { helpers.blacklight_config.institution_field => [@institution_title || parent_document[helpers.blacklight_config.index.title_field]] }
                     else
                       { helpers.blacklight_config.institution_field => [parent_document[helpers.blacklight_config.institution_field]],
                         helpers.blacklight_config.collection_field => [parent_document[helpers.blacklight_config.index.title_field.to_sym]] }
                     end
      link_to(I18n.t("blacklight.#{context}.browse.all"), search_catalog_path(f: facet_params), class: classes)
    end

    def context
      parent_document.fetch(helpers.blacklight_config.index.display_type_field)&.downcase&.pluralize
    end

    def render?
      featured_documents.present?
    end
  end
end
