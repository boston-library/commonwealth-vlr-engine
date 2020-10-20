# frozen_string_literal: true

class CommonwealthMltSearchBuilder < Blacklight::SearchBuilder
  include Blacklight::Solr::SearchBuilderBehavior
  include BlacklightMaps::MapsSearchBuilderBehavior
  include BlacklightRangeLimit::RangeLimitBuilder
  include CommonwealthVlrEngine::CommonwealthSearchBuilderBehavior

  self.default_processor_chain += [
    :site_filter, :mlt_params, :exclude_unpublished_items
  ]

  self.default_processor_chain += [:institution_limit, :exclude_institutions] unless I18n.t('blacklight.home.browse.institutions.enabled')
end
