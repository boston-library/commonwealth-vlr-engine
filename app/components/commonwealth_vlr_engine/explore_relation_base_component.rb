# frozen_string_literal: true

# render a component for #show views to include information about an institution or collection
module CommonwealthVlrEngine
  class ExploreRelationBaseComponent < ViewComponent::Base
    attr_reader :parent_document, :explore_document #, :explore_exemplary_document

    # @param [SolrDocument] parent_document - the document on which we want to display this component
    def initialize(parent_document:)
      @parent_document = parent_document
      @explore_document = fetch_explore_document
    end

    def fetch_explore_document
      explore_doc_class = context == 'digitalobjects' ? 'admin_set' : 'institution'
      SolrDocument.find(parent_document["#{explore_doc_class}_ark_id_ssi"])
    end

    def explore_exemplary_document
      # TODO: case when @document['exemplary_image_digobj_ss'] not set (throws Blacklight::Exceptions::RecordNotFound)
      SolrDocument.find(explore_document[:exemplary_image_digobj_ss])
      # SolrDocument.find('bpl-dev:6q182k915')
    end

    # can't use helpers here because this gets called during initialize
    def context
      @parent_document.fetch(:curator_model_suffix_ssi)&.downcase&.pluralize
    end

    def explore_image_tag
      image_tag(helpers.banner_image_url(exemplary_document: explore_exemplary_document,
                                         target_height: 400,
                                         target_width: 550),
                alt: explore_document[helpers.blacklight_config.index.title_field.field],
                class: 'explore-image')
    end

    def explore_link
      link_to(explore_document[helpers.blacklight_config.index.title_field.field],
              helpers.public_send(explore_path, id: explore_document[:id]), id: 'explore_link')
    end

    def explore_text
      return if explore_document['abstract_tsi'].blank?

      helpers.index_abstract({ value: [explore_document['abstract_tsi']], document: explore_document,
                               path_helper: explore_path, truncate_length: 600 })
    end

    def explore_path
      context == 'digitalobjects' ? :collection_path : :institution_path
    end

    def render?
      return if explore_document.blank?

      return if context == 'collections' && CommonwealthVlrEngine.config.dig(:institution, :pid).present?

      true
    end
  end
end
