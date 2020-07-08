module CommonwealthVlrEngine
  module CollectionsControllerBehavior
    extend ActiveSupport::Concern
    ##
    # Give CollectionsController access to the CatalogController configuration
    include Blacklight::Configurable

    included do
      copy_blacklight_config_from(CatalogController)

      # remove collection facet and collapse others
      before_action :relation_base_blacklight_config, :only => [:index, :show]
      before_action :add_series_facet, :only => :show
      before_action :collections_limit, :only => :index
      before_action :collections_limit_for_facets, :only => :facet
      before_action :collapse_institution_facet, :only => :index

      helper_method :search_action_url
      helper_method :get_series_image_obj
    end

    def index
      @nav_li_active = 'explore'
      (@response, @document_list) = search_service.search_results
      params[:view] = 'list'
      params[:sort] = 'title_info_primary_ssort asc'

      respond_to do |format|
        format.html
      end
    end

    def show
      @nav_li_active = 'explore'
      _show_response, @document = search_service.fetch(params[:id])
      @collection_title = @document[blacklight_config.index.title_field.to_sym]

      # get the response for the facets representing items in collection
      facets_search_service = search_service_class.new(config: blacklight_config,
                                                       user_params: { f: set_collection_facet_params(@collection_title,
                                                                                                     @document) })
      @response, @document_list = facets_search_service.search_results

      # get an image for the collection
      if @document[:exemplary_image_ssi]
        @collection_image_pid = @document[:exemplary_image_ssi]
        @collection_image_info = get_collection_image_info(@collection_image_pid,
                                                           @document[:id])
      end

      respond_to do |format|
        format.html
      end

    end

    def range_limit
      redirect_to range_limit_catalog_path(params.permit!.except('controller', 'action')) and return
    end

    protected

    # Blacklight uses #search_action_url to figure out the right URL for the global search box
    def search_action_url options = {}
      search_catalog_url(options.except(:controller, :action))
    end

    # find a representative image/item for a series
    def get_series_image_obj(series_title,collection_title)
      blacklight_config.search_builder_class = CommonwealthFlaggedSearchBuilder # ignore flagged items
      series_params = { f: { @series_field => series_title,
                             blacklight_config.collection_field => collection_title },
                       rows: 1 }
      series_search_service = search_service_class.new(config: blacklight_config,
                                                       user_params: series_params)
      _series_response, series_doc_list = series_search_service.search_results
      series_doc_list.first
    end

    # show series facet
    def add_series_facet
      @series_field = 'related_item_series_ssim'
      blacklight_config.facet_fields[@series_field].include_in_request = true
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
      _col_img_file_resp, col_img_file_doc = search_service.fetch(image_pid)
      if col_img_file_doc
        col_img_info[:access_master] = true if col_img_file_doc[:is_image_of_ssim]
        col_img_field = col_img_file_doc[:is_image_of_ssim].presence || col_img_file_doc[:is_file_of_ssim].presence
        if col_img_field
          col_img_obj_pid = col_img_field.first.gsub(/info:fedora\//,'')
          _col_img_obj_resp, col_img_obj_doc = search_service.fetch(col_img_obj_pid)
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
      facet_params[blacklight_config.institution_field] = document[blacklight_config.institution_field.to_sym] if t('blacklight.home.browse.institutions.enabled')
      facet_params
    end
  end
end
