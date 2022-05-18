# frozen_string_literal: true

# corresponds to IIIF Annotation resource
module BlacklightIiifSearch
  class IiifSearchAnnotation
    include IIIF::Presentation
    include BlacklightIiifSearch::AnnotationBehavior

    attr_reader :document, :query, :hl_index, :snippet, :controller,
                :parent_document, :hl_term_index

    ##
    # @param document [SolrDocument]
    # @param query [String]
    # @param hl_index [Integer]
    # @param snippet [String]
    # @param controller [CatalogController]
    # @param parent_document [SolrDocument]
    # @param hl_term_index [Integer] index of highlighted term within snippet
    # rubocop:disable Metrics/ParameterLists
    def initialize(document, query, hl_index, snippet, controller, parent_document, hl_term_index)
      @document = document
      @query = query
      @hl_index = hl_index
      @snippet = snippet
      @controller = controller
      @parent_document = parent_document
      @hl_term_index = hl_term_index
    end
    # rubocop:enable Metrics/ParameterLists

    ##
    # @return [IIIF::Presentation::Annotation]
    def as_hash
      annotation = IIIF::Presentation::Annotation.new('@id' => annotation_id)
      annotation.resource = text_resource_for_annotation if snippet
      annotation['on'] = canvas_uri_for_annotation
      annotation
    end

    ##
    # @return [IIIF::Presentation::Resource]
    def text_resource_for_annotation
      clean_snippet = ActionView::Base.full_sanitizer.sanitize(snippet)
      IIIF::Presentation::Resource.new('@type' => 'cnt:ContentAsText',
                                       'chars' => clean_snippet)
    end
  end
end
