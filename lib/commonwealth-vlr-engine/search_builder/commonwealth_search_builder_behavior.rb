# frozen_string_literal: true

module CommonwealthVlrEngine
  module CommonwealthSearchBuilderBehavior
    # only return items corresponding to the correct site
    def site_filter(solr_parameters = {})
      solr_parameters[:fq] ||= []
      solr_parameters[:fq] << '+destination_site_ssim:"' + CommonwealthVlrEngine.config[:site] + '"'
    end

    # keep file assets from appearing in search results
    # we don't really need this because Filestream::* objects don't have destination_site_ssim
    # values, so they are already excluded by CommonwealthSearchBuilderBehavior#site_filter
    # but keeping this in case we need it in the future
    def exclude_unwanted_models(solr_parameters = {})
      solr_parameters[:fq] ||= []
    end

    # keep draft/review and in-process items from appearing in search results
    def exclude_unpublished_items(solr_parameters = {})
      solr_parameters[:fq] ||= []
      solr_parameters[:fq] << '-publishing_state_ssi:"draft"'
      solr_parameters[:fq] << '-publishing_state_ssi:"needs_review"'
      solr_parameters[:fq] << '-processing_state_ssi:"derivatives"'
    end

    # keep Institution objects out of the search results
    def exclude_institutions(solr_parameters = {})
      solr_parameters[:fq] ||= []
      solr_parameters[:fq] << '-curator_model_suffix_ssi:"Institution"'
    end

    # keep Collection objects out of the search results
    def exclude_collections(solr_parameters = {})
      solr_parameters[:fq] ||= []
      solr_parameters[:fq] << '-curator_model_suffix_ssi:"Collection"'
    end

    # don't return flagged items (for series images on collections#show)
    def flagged_filter(solr_parameters = {})
      solr_parameters[:fq] ||= []
      solr_parameters[:fq] << "-#{blacklight_config.flagged_field}:[* TO *]"
    end

    # limit results to a single institution
    def institution_limit(solr_parameters = {})
      solr_parameters[:fq] ||= []
      solr_parameters[:fq] << '+institution_ark_id_ssi:"' + CommonwealthVlrEngine.config[:institution][:pid] + '"'
    end

    # used by InstitutionsController#index
    def institutions_filter(solr_parameters = {})
      solr_parameters[:fq] ||= []
      solr_parameters[:fq] << '+curator_model_suffix_ssi:"Institution"'
    end

    # for 'more like this' search -- set solr id param to params[:mlt_id]
    def mlt_params(solr_parameters = {})
      solr_parameters[:id] = blacklight_params[:mlt_id]
      solr_parameters[:qt] = 'mlt_qparser'
      solr_parameters[:qf] = 'subject_facet_ssim^10 subject_geo_city_sim^5 related_item_host_ssim'
    end

    # used by CollectionsController#index
    def collections_filter(solr_parameters = {})
      solr_parameters[:fq] ||= []
      solr_parameters[:fq] << '+curator_model_suffix_ssi:"Collection"'
    end

    # set params for ocr field searching
    def ocr_search_params(solr_parameters = {})
      solr_parameters[:facet] = false
      solr_parameters[:hl] = true
      solr_parameters[:'hl.fl'] = blacklight_config.ocr_search_field
      solr_parameters[:'hl.fragsize'] = 135
      solr_parameters[:'hl.snippets'] = 10
    end
  end
end
