# frozen_string_literal: true

class CommonwealthCollectionsSearchBuilder < Blacklight::SearchBuilder
  include Blacklight::Solr::SearchBuilderBehavior
  include CommonwealthVlrEngine::CommonwealthSearchBuilderBehavior

  self.default_processor_chain += [
    :site_filter, :exclude_unpublished_items, :collections_filter
  ]

  self.default_processor_chain += [:institution_limit] unless I18n.t('blacklight.home.browse.institutions.enabled')
end
