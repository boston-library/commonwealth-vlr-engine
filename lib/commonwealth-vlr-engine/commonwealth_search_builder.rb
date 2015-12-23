module CommonwealthVlrEngine
  module CommonwealthSearchBuilder

    # keep file assets from appearing in search results
    def exclude_unwanted_models(solr_parameters = {})
      solr_parameters[:fq] ||= []
      solr_parameters[:fq] << '-has_model_ssim:"info:fedora/afmodel:Bplmodels_File"'
    end

    # keep draft/review and in-process items from appearing in search results
    def exclude_unpublished_items(solr_parameters = {})
      solr_parameters[:fq] ||= []
      solr_parameters[:fq] << '-workflow_state_ssi:"draft"'
      solr_parameters[:fq] << '-workflow_state_ssi:"needs_review"'
      solr_parameters[:fq] << '-processing_state_ssi:"derivatives"'
      # can't implement below until all records have this field
      # solr_parameters[:fq] << '+workflow_state_ssi:"published"'
      # solr_parameters[:fq] << '+processing_state_ssi:"complete"'
    end

    # keep Institution objects out of the search results
    def exclude_institutions(solr_parameters = {})
      solr_parameters[:fq] ||= []
      solr_parameters[:fq] << '-active_fedora_model_suffix_ssi:"Institution"'
    end

    # don't return flagged items (for series images on collections#show)
    def flagged_filter(solr_parameters = {})
      solr_parameters[:fq] ||= []
      solr_parameters[:fq] << "-#{blacklight_config.flagged_field}:[* TO *]"
    end

    # used by InstitutionsController#index
    def institutions_filter(solr_parameters = {})
      solr_parameters[:fq] ||= []
      solr_parameters[:fq] << "+active_fedora_model_suffix_ssi:\"Institution\""
    end

    # for 'more like this' search -- set solr id param to params[:mlt_id]
    def set_solr_id_for_mlt(solr_parameters = {})
      solr_parameters[:id] = blacklight_params[:mlt_id]
    end

    # used by CollectionsController#index
    def collections_filter(solr_parameters = {})
      solr_parameters[:fq] ||= []
      solr_parameters[:fq] << "+active_fedora_model_suffix_ssi:\"Collection\""
    end

    # keep Volume objects out of the search results
    def exclude_volumes(solr_parameters = {})
      solr_parameters[:fq] ||= []
      solr_parameters[:fq] << '-active_fedora_model_suffix_ssi:"Volume"'
    end

    # set params for ocr field searching
    def ocr_search_params(solr_parameters = {})
      solr_parameters[:hl] = true
      solr_parameters[:'hl.fl'] = blacklight_config.ocr_search_field
      solr_parameters[:'hl.fragsize'] = 150
      solr_parameters[:fl] = "id, #{blacklight_config.page_num_field}"
    end

  end
end