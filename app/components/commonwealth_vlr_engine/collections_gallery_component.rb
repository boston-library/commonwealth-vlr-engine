# frozen_string_literal: true

module CommonwealthVlrEngine
  class CollectionsGalleryComponent < ViewComponent::Base
    attr_reader :collection_documents #, :parent_document

    def initialize(collection_documents: [])
      @collection_documents = collection_documents
      # @parent_document = parent_document
    end

    def view_config
      helpers.blacklight_config&.view_config(:masonry)
    end

    def collection_documents_presenters
      collection_documents.map { |doc| CommonwealthVlrEngine::IndexPresenter.new(doc, controller.view_context) }
    end

    def render?
      collection_documents.present?
    end
  end
end
