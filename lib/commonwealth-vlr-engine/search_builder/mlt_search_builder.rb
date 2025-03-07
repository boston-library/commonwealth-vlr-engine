# frozen_string_literal: true

module CommonwealthVlrEngine
  class MltSearchBuilder < Blacklight::SearchBuilder
    include Blacklight::Solr::SearchBuilderBehavior
    # include BlacklightMaps::MapsSearchBuilderBehavior
    include BlacklightRangeLimit::RangeLimitBuilder
    include CommonwealthVlrEngine::SearchBuilderBehavior

    self.default_processor_chain += [
      :site_filter, :mlt_params, :exclude_unpublished_items, :institution_limit, :exclude_institutions
    ]
  end
end
