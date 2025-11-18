# frozen_string_literal: true

# display a selection of items matching a facet value,
# either randomly derived from SolrDocument or Blacklight::Solr::Response, or provided as an arg.
module CommonwealthVlrEngine
  class FacetMoreComponent < ViewComponent::Base
    attr_reader :document, :response, :subject_fields, :subject_term, :item_count, :term_to_explore

    def initialize(document: {}, response: nil, subject_fields: %w[subject_facet_ssim subject_geographic_sim],
                   subject_term: nil, item_count: 4)
      @document = document
      @response = response
      @subject_fields = subject_fields
      @subject_term = subject_term
      @item_count = item_count
      @term_to_explore = term_data
    end

    def facet_more_documents_presenters
      facet_more_documents.map do |doc|
        CommonwealthVlrEngine::IndexPresenter.new(doc, controller.view_context,
                                                  view_config: helpers.blacklight_config.view_config(:index))
      end
    end

    def term_data
      t_data = { field_name: @subject_fields.first, value: @subject_term }
      @subject_fields.each do |sf|
        next if t_data[:value] || (document[sf].blank? && response&.aggregations&.dig(sf)&.items.blank?)

        t_data = { field_name: sf,
                      value: (document[sf] ||
                              response&.aggregations&.dig(sf)&.items&.map(&:value))[0..2].sample }
      end
      t_data
    end

    def facet_more_documents
      facet_search_params = { f: facet_more_params, sort: "#{helpers.blacklight_config.index.random_field} asc", rows: 50 }
      facet_search_service = Blacklight::SearchService.new(user_params: facet_search_params,
                                                           config: helpers.blacklight_config,
                                                           search_builder_class: FlaggedSearchBuilder)
      facet_search_service.search_results.documents.shuffle[0..(item_count - 1)] || []
    end

    def facet_more_params
      new_facet_params = { term_to_explore[:field_name] => term_to_explore[:value] }

      return new_facet_params if response&.aggregations.blank?

      # extract existing fq params from response, which is an Array like:
      # ["{!term f=field_name1_ssim}Foo Bar", "{!term f=field_name2_ssim}Baz--Qux", ...]
      previous_facet_params = response.params.dig('fq')
      previous_facet_params.each do |pfp|
        next unless pfp.match?(/{!term\sf=/)

        pfp_field_name = pfp.match(/f=[\w]*/)&.to_s&.delete_prefix('f=')
        pfp_field_value = pfp.split(/{!term\sf=[\w]*}/)&.last
        next unless pfp_field_name && pfp_field_value

        new_facet_params[pfp_field_name] = pfp_field_value
      end
      new_facet_params
    end

    def render?
      (subject_fields.any? { |sf| document[sf].present? || response&.aggregations&.dig(sf)&.items.present? }) ||
        subject_term.present?
    end
  end
end
