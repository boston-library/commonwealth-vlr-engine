# frozen_string_literal: true

module CommonwealthVlrEngine
  class OcrSearchBuilder < Blacklight::SearchBuilder
    include Blacklight::Solr::SearchBuilderBehavior
    include CommonwealthVlrEngine::SearchBuilderBehavior

    self.default_processor_chain += [
      :exclude_unpublished_items, :ocr_search_params
    ]
  end
end
