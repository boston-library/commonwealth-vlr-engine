# frozen_string_literal: true

module CommonwealthVlrEngine
  module InstitutionsControllerBehavior
    extend ActiveSupport::Concern
    ##
    # Give InstitutionsController access to the CatalogController configuration
    include Blacklight::Configurable

    included do
      copy_blacklight_config_from(CatalogController)

      before_action :institutions_index_config, :only => [:index]
      before_action :relation_base_blacklight_config, :only => [:show]

      helper_method :search_action_url
    end

    def index
      @nav_li_active = 'explore'
      params.merge!(view: params[:view].presence || 'list',
                    per_page: params[:per_page].presence || '50',
                    sort: blacklight_config.title_sort)
      institutions_search_service = search_service_class.new(config: blacklight_config,
                                                             user_params: params)
      @response = institutions_search_service.search_results

      respond_to do |format|
        format.html
      end
    end

    def show
      @nav_li_active = 'explore'

      # have to define a new search_service here, or we can't inject params[:f] below
      institution_search_service = search_service_class.new(config: blacklight_config,
                                                            user_params: params)
      @document = institution_search_service.fetch(params[:id])
      @institution_title = @document[blacklight_config.index.title_field.to_sym]

      # get the response for collection objects
      collex_params = { f: { blacklight_config.index.display_type_field => 'Collection',
                             'institution_ark_id_ssi' => params[:id] },
                        rows: 500, sort: blacklight_config.title_sort }
      collex_search_service = search_service_class.new(config: blacklight_config,
                                                       user_params: collex_params)
      @collex_documents = collex_search_service.search_results&.documents

      # add params[:f] for proper facet links, get response for items in collection
      params.merge!(f: { blacklight_config.institution_field => [@institution_title] }).permit!
      facets_search_service = search_service_class.new(config: blacklight_config,
                                                       user_params: { f: params[:f] })
      @response = facets_search_service.search_results

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

    # remove grid view from blacklight_config, use correct SearchBuilder for index view
    def institutions_index_config
      blacklight_config.search_builder_class = CommonwealthInstitutionsSearchBuilder
      blacklight_config.view.delete(:gallery)
      blacklight_config.view.delete(:masonry)
      blacklight_config.view.delete(:slideshow)
    end
  end
end
