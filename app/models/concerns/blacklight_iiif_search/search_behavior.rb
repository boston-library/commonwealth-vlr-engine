# frozen_string_literal: true

module BlacklightIiifSearch
  module SearchBehavior
    ##
    # limit the search to items that have some relationship with the parent object (e.g. pages)
    # return a hash with:
    # key:   solr field for image/file to object relationship
    # value: identifier to match
    # TODO: use blacklight_config.index.display_type_field once
    # https://github.com/boston-library/blacklight_iiif_search/issues/5 is resolved
    def object_relation_solr_params
      { iiif_config[:object_relation_field] => id,
        iiif_config[:page_model_field] => 'Image' } # 'curator_model_suffix_ssi'
    end
  end
end
