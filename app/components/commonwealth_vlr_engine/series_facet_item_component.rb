# frozen_string_literal: true

module CommonwealthVlrEngine
  class SeriesFacetItemComponent < Blacklight::FacetItemComponent
    def render_facet_value
      tag.div(class: 'series_facet') do
        tag.div(class: 'thumbnail-container') do
          link_to(helpers.create_thumb_img_element(document_for_series, %w(series_thumbnail)),
                  href, rel: 'nofollow')
        end +
        tag.div(class: 'caption-area') do
          tag.span(class: 'facet-label') do
            link_to_unless(@suppress_link, label, href, class: 'facet-select', rel: 'nofollow')
          end
        end
      end
    end

    def document_for_series
      series_params = { f: { blacklight_config.series_field => label,
                             blacklight_config.collection_field => collection_name },
                        rows: 1 }
      series_search_service = Blacklight::SearchService.new(config: blacklight_config,
                                                            user_params: series_params,
                                                            search_builder_class: CommonwealthVlrEngine::FlaggedSearchBuilder)
      series_response = series_search_service.search_results
      series_response.documents.first
    end

    # have to extract the collection name from the search URL
    def collection_name
      CGI.unescape(href.split('&f%5B').find { |h| h.include?('collection_name') }.split('%5D=').last)
    end

    delegate :blacklight_config, to: :helpers
  end
end
