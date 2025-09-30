# frozen_string_literal: true

module CommonwealthVlrEngine
  module CollectionsControllerBehavior
    extend ActiveSupport::Concern
    # Give CollectionsController access to the CatalogController configuration
    include Blacklight::Configurable

    included do
      copy_blacklight_config_from(CatalogController)

      before_action :nav_li_active, only: [:index, :show]
      before_action :collections_index_config, only: :index
      before_action :collections_show_config, only: :show
      before_action :add_series_facet, only: :show

      # methods below are DEPRECATED, but possibly needed in the future
      # before_action :collapse_institution_facet, only: :index
      # before_action :collections_limit_for_facets, only: :facet
      # before_action :relation_base_blacklight_config, only: [:index, :show]
    end

    def index
      params.merge!(view: 'gallery', sort: blacklight_config.title_sort)
      collection_search_service = search_service_class.new(config: blacklight_config,
                                                           user_params: params)
      @response = collection_search_service.search_results

      respond_to do |format|
        format.html
      end
    end

    def show
      # have to define a new search_service here, or we can't inject params[:f] below
      collection_search_service = search_service_class.new(config: blacklight_config,
                                                           user_params: params)
      @document = collection_search_service.fetch(params[:id])
      @collection_title = @document[blacklight_config.index.title_field.field]
      @exemplary_document = @document[:exemplary_image_digobj_ss] ? collection_search_service.fetch(@document[:exemplary_image_digobj_ss]) : nil

      # add params[:f] for proper facet links
      params.merge!(f: set_collection_facet_params(@collection_title, @document)).permit!

      # get the response for the facets representing items in collection
      facets_search_service = search_service_class.new(
        config: blacklight_config,
        user_params: { f: params[:f], sort: "#{blacklight_config.index.random_field} asc"}
      )
      @response = facets_search_service.search_results
      @featured_items = @response&.documents&.sample(8)

      respond_to do |format|
        format.html
      end
    end

    def range_limit
      redirect_to range_limit_catalog_path(params.permit!.except('controller', 'action')) and return
    end

    protected

    # need to use different methods depending on controller action so search links are correct
    def search_action_url options = {}
      if action_name == 'index'
        # Blacklight::Catalog#search_action_url
        options = options.to_h if options.is_a? Blacklight::SearchState
        url_for(options.reverse_merge(action: 'index'))
      else
        # Blacklight::Controller#search_action_url
        search_catalog_url(options.to_h.except(:controller, :action))
      end
    end

    # add series facet for collections#show
    def add_series_facet
      blacklight_config.facet_fields[blacklight_config.series_field].include_in_request = true
    end

    # find only collection objects
    def collections_index_config
      blacklight_config.search_builder_class = CommonwealthVlrEngine::CollectionsSearchBuilder
      blacklight_config.index.search_header_component = CommonwealthVlrEngine::CollectionsSearchHeaderComponent
      blacklight_config.facet_fields[:genre_basic_ssim].limit = 20
      blacklight_config.view.delete(:list)
      blacklight_config.view.delete(:masonry)
      blacklight_config.view.delete(:slideshow)
    end

    def collections_show_config
      blacklight_config.show.metadata_component = nil
      blacklight_config.search_fields.delete(:title)
      blacklight_config.search_fields.delete(:subject)
      blacklight_config.search_fields.delete(:place)
      blacklight_config.search_fields.delete(:creator)
      blacklight_config.advanced_search.enabled = false
    end

    # set the correct facet params for facets from the collection
    def set_collection_facet_params(collection_title, document)
      facet_params = { blacklight_config.collection_field => [collection_title] }
      facet_params[blacklight_config.institution_field] = [document[blacklight_config.institution_field.to_sym]] if CommonwealthVlrEngine.config.dig(:institution, :pid).blank?
      facet_params
    end

    def nav_li_active
      @nav_li_active = 'explore'
    end

    ##
    # methods below are DEPRECATED, but possibly needed in the future

    # collapse the institution facet, if Institutions supported
    # def collapse_institution_facet
    #   return if CommonwealthVlrEngine.config.dig(:institution, :pid).present?
    #
    #   blacklight_config.facet_fields['physical_location_ssim'].collapse = true
    # end

    # find object data for "more" facet results
    # collections#facet can be called within BOTH collections#index and collections#show contexts
    # when collections#index, want to limit to collection objects
    # when collections#show, should be objects that are child of collection
    # so we use the check below, since request.query_parameters['f'] is only added in collections#show
    # via set_collection_facet_params
    # def collections_limit_for_facets
    #   return if request.query_parameters['f'] && request.query_parameters['f'][blacklight_config.collection_field]
    #
    #   collections_limit
    # end
  end
end
