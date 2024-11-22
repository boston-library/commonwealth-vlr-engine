# frozen_string_literal: true

class CommonwealthInstitutionsSearchBuilder < Blacklight::SearchBuilder
  include Blacklight::Solr::SearchBuilderBehavior
  # include BlacklightMaps::MapsSearchBuilderBehavior
  include CommonwealthVlrEngine::CommonwealthSearchBuilderBehavior

  self.default_processor_chain += [
    :site_filter, :exclude_unpublished_items, :institutions_filter
  ]
end
