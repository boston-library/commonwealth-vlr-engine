# frozen_string_literal: true

module CommonwealthVlrEngine
  class FeaturedItemsComponent < ViewComponent::Base
    attr_reader :featured_documents, :context

    def initialize(featured_documents: [], context: 'collections')
      @featured_documents = featured_documents
      @context = context
    end

    def view_config
      helpers.blacklight_config&.view_config(:masonry)
    end

    def featured_documents_presenters
      featured_documents.map { |doc| CommonwealthVlrEngine::IndexPresenter.new(doc, controller.view_context) }
    end

    def render?
      featured_documents.present?
    end
  end
end
