class CommonwealthSearchBuilder < Blacklight::SearchBuilder
  include Blacklight::Solr::SearchBuilderBehavior
  include BlacklightAdvancedSearch::AdvancedSearchBuilder
  include BlacklightMaps::MapsSearchBuilderBehavior
  include BlacklightRangeLimit::RangeLimitBuilder
  include CommonwealthVlrEngine::CommonwealthSearchBuilderBehavior

  self.default_processor_chain += [
      :site_filter, :exclude_unwanted_models, :exclude_unpublished_items, :exclude_volumes,
      :add_advanced_parse_q_to_solr, :add_advanced_search_to_solr
  ]

  unless I18n.t('blacklight.home.browse.institutions.enabled')
    self.default_processor_chain += [:institution_limit, :exclude_institutions]
  end
end
