# frozen_string_literal: true

module CommonwealthVlrEngine
  class MltFilterQuery
    # return a blank string, since we don't actually want to add any params to facet query
    # (but this class is needed or MLT search won't return results correctly)
    # wrangling of solr_params is done via CommonwealthVlrEngine::MltSearchBuilder
    def self.call(_search_builder, _filter, _solr_params)
      ''
    end
  end
end
