# frozen_string_literal: true

# display a selection of items matching a facet value
module CommonwealthVlrEngine
  class FacetMoreComponent < ViewComponent::Base
    attr_reader :response, :subject_fields, :document

    def initialize(response: nil, subject_fields: %w[subject_facet_ssim subject_geographic_sim], parent_document: nil)
      @response = response
      @subject_fields = subject_fields
      @parent_document = parent_document
    end

    def facet_more_documents_presenters
      facet_documents.map { |doc| CommonwealthVlrEngine::IndexPresenter.new(doc, controller.view_context) }
    end

    def term_to_explore
      term_data = { value: nil }
      subject_fields.each do |sf|
        next if term_data[:value] || response.aggregations.dig(sf).blank?

        term_data = { field_name: sf, value: response.aggregations.dig(sf).items[0..2].sample.value }
      end
      term_data
    end

    def facet_documents
      # TODO: retrieve documents matching params from term_to_explore
      []
    end

    def render?
      subject_fields.any? { |sf| response.aggregations.dig(sf).present? }
    end
  end
end
