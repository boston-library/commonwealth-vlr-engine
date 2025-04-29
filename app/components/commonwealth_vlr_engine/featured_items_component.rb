# frozen_string_literal: true

module CommonwealthVlrEngine
  class FeaturedItemsComponent < ViewComponent::Base
    attr_reader :featured_documents, :context

    def initialize(featured_documents: [], context: 'collections')
      @featured_documents = featured_documents.map { |doc| Blacklight::DocumentPresenter.new(doc, CatalogController) }
      @context = context
    end

    def render?
      featured_documents.present?
    end
  end
end
