# frozen_string_literal: true

module CommonwealthVlrEngine
  class CollectionsSearchBuilder < Blacklight::SearchBuilder
    include Blacklight::Solr::SearchBuilderBehavior
    include CommonwealthVlrEngine::SearchBuilderBehavior

    self.default_processor_chain += [
      :site_filter, :exclude_unpublished_items, :collections_filter, :institution_limit
    ]
  end
end
