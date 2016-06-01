class CommonwealthCollectionsSearchBuilder < Blacklight::SearchBuilder

  include Blacklight::Solr::SearchBuilderBehavior
  include CommonwealthVlrEngine::CommonwealthSearchBuilderBehavior

  self.default_processor_chain += [
      :exclude_unpublished_items, :collections_filter
  ]

end