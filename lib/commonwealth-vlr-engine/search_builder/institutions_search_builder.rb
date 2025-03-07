# frozen_string_literal: true

module CommonwealthVlrEngine
  class InstitutionsSearchBuilder < Blacklight::SearchBuilder
    include Blacklight::Solr::SearchBuilderBehavior
    # include BlacklightMaps::MapsSearchBuilderBehavior
    include CommonwealthVlrEngine::SearchBuilderBehavior

    self.default_processor_chain += [
      :site_filter, :exclude_unpublished_items, :institutions_filter
    ]
  end
end
