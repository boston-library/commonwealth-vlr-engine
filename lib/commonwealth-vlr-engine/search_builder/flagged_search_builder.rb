class CommonwealthFlaggedSearchBuilder < Blacklight::SearchBuilder

  include Blacklight::Solr::SearchBuilderBehavior
  include CommonwealthVlrEngine::CommonwealthSearchBuilderBehavior

  self.default_processor_chain += [
      :exclude_unpublished_items, :flagged_filter
  ]

end