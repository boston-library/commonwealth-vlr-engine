class CommonwealthInstitutionsSearchBuilder < Blacklight::SearchBuilder

  include Blacklight::Solr::SearchBuilderBehavior
  include CommonwealthVlrEngine::CommonwealthSearchBuilderBehavior

  self.default_processor_chain += [
      :exclude_unpublished_items, :institutions_filter
  ]

end