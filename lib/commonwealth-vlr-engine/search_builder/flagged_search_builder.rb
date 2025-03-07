# frozen_string_literal: true

module CommonwealthVlrEngine
  class FlaggedSearchBuilder < Blacklight::SearchBuilder
    include Blacklight::Solr::SearchBuilderBehavior
    include CommonwealthVlrEngine::SearchBuilderBehavior

    self.default_processor_chain += [
      :site_filter, :exclude_unpublished_items, :flagged_filter, :institution_limit
    ]
  end
end
