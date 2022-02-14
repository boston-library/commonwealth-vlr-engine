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

    # override Blacklight::Solr::SearchBuilderBehavior
    # so we can add `solr_parameters[:defType] = 'lucene'` for multifield search query,
    # needed for Solr >= 8 (?)
    def add_query_to_solr(solr_parameters)
      ###
      # Merge in search field configured values, if present, over-writing general
      # defaults
      ###
      # legacy behavior of user param :qt is passed through, but over-ridden
      # by actual search field config if present. We might want to remove
      # this legacy behavior at some point. It does not seem to be currently
      # rspec'd.
      solr_parameters[:qt] = blacklight_params[:qt] if blacklight_params[:qt]

      if search_field
        solr_parameters[:qt] = search_field.qt
        solr_parameters.merge!( search_field.solr_parameters) if search_field.solr_parameters
      end

      ##
      # Create Solr 'q' including the user-entered q, prefixed by any
      # solr LocalParams in config, using solr LocalParams syntax.
      # http://wiki.apache.org/solr/LocalParams
      ##
      if search_field && search_field.solr_local_parameters.present?
        local_params = search_field.solr_local_parameters.map do |key, val|
          key.to_s + "=" + solr_param_quote(val, :quote => "'")
        end.join(" ")
        solr_parameters[:q] = "{!#{local_params}}#{blacklight_params[:q]}"

        ##
        # Set Solr spellcheck.q to be original user-entered query, without
        # our local params, otherwise it'll try and spellcheck the local
        # params!
        solr_parameters["spellcheck.q"] ||= blacklight_params[:q]
      elsif blacklight_params[:q].is_a? Hash
        q = blacklight_params[:q]
        solr_parameters[:q] = if q.values.any?(&:blank?)
                                # if any field parameters are empty, exclude _all_ results
                                "{!lucene}NOT *:*"
                              else
                                "{!lucene}" + q.map do |field, values|
                                  "#{field}:(#{Array(values).map { |x| solr_param_quote(x) }.join(" OR ")})"
                                end.join(" AND ")
                              end

        solr_parameters[:defType] = 'lucene'
        solr_parameters[:spellcheck] = 'false'
      elsif blacklight_params[:q]
        solr_parameters[:q] = blacklight_params[:q]
      end
    end
  end
end