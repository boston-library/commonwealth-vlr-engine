module CommonwealthVlrEngine
  module CollectionsControllerBehavior
    extend ActiveSupport::Concern
    ##
    # Give CollectionsController access to the CatalogController configuration
    include Blacklight::Configurable
    include Blacklight::SearchHelper

    included do
      copy_blacklight_config_from(CatalogController)

      # remove collection facet and collapse others
      before_filter :relation_base_blacklight_config, :only => [:index, :show]
      before_filter :add_series_facet, :only => :show
      before_filter :collections_limit, :only => :index
      before_filter :collections_limit_for_facets, :only => :facet
      before_filter :collapse_institution_facet, :only => :index

      helper_method :search_action_url
      helper_method :get_series_image_obj
    end

    def index
      @nav_li_active = 'explore'
      (@response, @document_list) = search_results(params)
      params[:view] = 'list'
      params[:sort] = 'title_info_primary_ssort asc'

      respond_to do |format|
        format.html
      end
    end

    def show
      @nav_li_active = 'explore'
      @show_response, @document = fetch(params[:id])
      @collection_title = @document[blacklight_config.index.title_field.to_sym]

      # add params[:f] for proper facet links
      params[:f] = set_collection_facet_params(@collection_title, @document)

      # get the response for the facets representing items in collection
      (@response, @document_list) = search_results({:f => params[:f]})

      # get an image for the collection
      if @document[:exemplary_image_ssi]
        @collection_image_pid = @document[:exemplary_image_ssi]
        @collection_image_key = @document[:exemplary_image_key_base_ss]
        @collection_image_info = get_collection_image_info(@collection_image_pid,
                                                           @document[:id])
      end

      respond_to do |format|
        format.html
      end

    end

    def range_limit
      redirect_to range_limit_catalog_path(params.except('controller', 'action')) and return
    end

    protected

    # Blacklight uses #search_action_url to figure out the right URL for the global search box
    def search_action_url options = {}
      search_catalog_url(options.except(:controller, :action))
    end

    # find a representative image/item for a series
    def get_series_image_obj(series_title,collection_title)
      blacklight_config.search_builder_class = CommonwealthFlaggedSearchBuilder # ignore flagged items
      series_doc_list = search_results({f: {'related_item_series_ssi' => series_title,
                                            blacklight_config.collection_field => collection_title},
                                        rows: 1})[1]
      series_doc_list.first
    end

    # show series facet
    def add_series_facet
      blacklight_config.facet_fields['related_item_series_ssi'].include_in_request = true
    end

    # collapse the institution facet, if Institutions supported
    def collapse_institution_facet
      return unless t('blacklight.home.browse.institutions.enabled')
      blacklight_config.facet_fields['physical_location_ssim'].collapse = true
    end

    # find only collection objects
    def collections_limit
      blacklight_config.search_builder_class = CommonwealthCollectionsSearchBuilder
    end

    # find object data for facet results
    # collections#facet can be called within BOTH collections#index and collections#show contexts
    # when collections#index, want to limit to collection objects
    # when collections#show, should be objects that are child of collection
    # so we use the check below, since request.query_parameters['f'] is only added in collections#show
    # via set_collection_facet_params
    def collections_limit_for_facets
      unless request.query_parameters['f'] && request.query_parameters['f'][blacklight_config.collection_field]
        self.collections_limit
      end
    end

    # find the title and pid for the object representing the collection image
    def get_collection_image_info(image_pid, collection_pid)
      col_img_info = {title: '', pid: collection_pid, access_master: false}
      col_img_file_doc = fetch(image_pid)[1]
      if col_img_file_doc
        col_img_info[:access_master] = true if col_img_file_doc[:is_file_set_of_ssim]
        col_img_field = col_img_file_doc[:is_file_set_of_ssim].presence
        if col_img_field
          col_img_obj_pid = col_img_field.first
          col_img_obj_doc = fetch(col_img_obj_pid)[1]
          if col_img_obj_doc
            col_img_info[:title] = col_img_obj_doc[blacklight_config.index.title_field.to_sym]
            col_img_info[:pid] = col_img_obj_pid
          end
        end
      end
      col_img_info
    end

    # set the correct facet params for facets from the collection
    def set_collection_facet_params(collection_title, document)
      facet_params = {blacklight_config.collection_field => [collection_title]}
      facet_params[blacklight_config.institution_field] = [document[blacklight_config.institution_field.to_sym]] if t('blacklight.home.browse.institutions.enabled')
      facet_params
    end
  end
end
