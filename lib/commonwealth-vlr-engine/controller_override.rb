module CommonwealthVlrEngine
  module ControllerOverride
    extend ActiveSupport::Concern
    included do

      # Extend Blacklight::Catalog with Hydra behaviors (primarily editing).
      self.send(:include, Hydra::Controller::ControllerBehavior)

      if self.respond_to? :search_params_logic
        search_params_logic << :exclude_unwanted_models
      end

      if self.blacklight_config.search_builder_class
        self.blacklight_config.search_builder_class.send(:include,
                                                         CommonwealthVlrEngine::CommonwealthSearchBuilder
        ) unless
            self.blacklight_config.search_builder_class.include?(
                CommonwealthVlrEngine::CommonwealthSearchBuilder
            )
      end

      before_filter :get_object_files, :only => [:show]
      before_filter :set_nav_context, :only => [:index]
      before_filter :mlt_search, :only => [:index]

    end

    # displays the MODS XML record. copied from blacklight_marc gem
    def librarian_view
      @response, @document = fetch(params[:id])

      respond_to do |format|
        format.html
        format.js { render :layout => false }
      end
    end

    # displays values and pagination links for Format field
    def formats_facet
      @nav_li_active = 'explore'

      @facet = blacklight_config.facet_fields['genre_basic_ssim']
      @response = get_facet_field_response(@facet.key, params)
      @display_facet = @response.aggregations[@facet.key]

      @pagination = facet_paginator(@facet, @display_facet)

      render :facet
    end

    # if this is 'more like this' search, solr id = params[:mlt_id]
    def mlt_search
      if params[:mlt_id]
        CatalogController.search_params_logic += [:set_solr_id_for_mlt]
      end
    end

    def get_object_files
      @object_files = Bplmodels::Finder.getFiles(params[:id])
    end

    def set_nav_context
      @nav_li_active = 'search'
    end


  end

end