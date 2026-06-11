# frozen_string_literal: true

# for catalog#show or collections#show views
# displays an image and description for the object's parent (collection or institution)
module CommonwealthVlrEngine
  class ParentPreviewComponent < ViewComponent::Base
    attr_reader :document, :parent_document

    # @param [SolrDocument] document - the document on which we want to display this component
    def initialize(document:)
      @document = document
      @parent_document = fetch_parent_document
    end

    def fetch_parent_document
      parent_doc_class = context == 'digitalobjects' ? 'admin_set' : 'institution'
      SolrDocument.find(document["#{parent_doc_class}_ark_id_ssi"])
    end

    def parent_exemplary_document
      parent_document[:exemplary_image_digobj_ss] ? SolrDocument.find(parent_document[:exemplary_image_digobj_ss]) : nil
    end

    # can't use helpers here because this gets called during initialize
    def context
      @document.fetch(:curator_model_suffix_ssi)&.downcase&.pluralize
    end

    def parent_image_tag
      image_tag(helpers.banner_image_url(exemplary_document: parent_exemplary_document,
                                         target_height: 350,
                                         target_width: 550),
                alt: parent_document[helpers.blacklight_config.index.title_field.field],
                class: 'parent-image')
    end

    def parent_link
      link_to(parent_document[helpers.blacklight_config.index.title_field.field],
              helpers.public_send(parent_path, id: parent_document[:id]), id: 'parent_link')
    end

    def parent_text
      return if parent_document['abstract_tsi'].blank?

      helpers.index_abstract({ value: [parent_document['abstract_tsi']], document: parent_document,
                               path_helper: parent_path, truncate_length: 600 })
    end

    def parent_path
      context == 'digitalobjects' ? :collection_path : :institution_path
    end

    def render?
      return if parent_document.blank?

      return if context == 'collections' && CommonwealthVlrEngine.config.dig(:institution, :pid).present?

      true
    end
  end
end
