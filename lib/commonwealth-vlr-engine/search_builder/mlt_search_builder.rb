class CommonwealthMltSearchBuilder < Blacklight::SearchBuilder

  include Blacklight::Solr::SearchBuilderBehavior
  include BlacklightMaps::MapsSearchBuilderBehavior
  include BlacklightRangeLimit::RangeLimitBuilder
  include CommonwealthVlrEngine::CommonwealthSearchBuilderBehavior

  self.default_processor_chain += [
      :site_filter, :mlt_params, :exclude_unpublished_items, :exclude_volumes
  ]

  unless I18n.t('blacklight.home.browse.institutions.enabled')
    self.default_processor_chain += [:institution_limit, :exclude_institutions]
  end

end