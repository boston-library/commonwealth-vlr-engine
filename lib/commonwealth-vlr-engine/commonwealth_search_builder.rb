module CommonwealthVlrEngine
  module CommonwealthSearchBuilder

    # keep file assets and unpublished items from appearing in search results
    def exclude_unwanted_models(solr_parameters = {})
      solr_parameters[:fq] ||= []
      solr_parameters[:fq] << '-has_model_ssim:"info:fedora/afmodel:Bplmodels_File"'
      solr_parameters[:fq] << '-workflow_state_ssi:"draft"'
      solr_parameters[:fq] << '-workflow_state_ssi:"needs_review"'
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

  end
end