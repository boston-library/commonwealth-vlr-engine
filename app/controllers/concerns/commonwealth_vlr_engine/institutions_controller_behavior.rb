module CommonwealthVlrEngine
  module InstitutionsControllerBehavior
    extend ActiveSupport::Concern
    ##
    # Give Bookmarks access to the CatalogController configuration
    include Blacklight::Configurable

    included do
      copy_blacklight_config_from(CatalogController)

      before_action :institutions_index_config, :only => [:index]
      # remove collection facet and collapse others
      before_action :relation_base_blacklight_config, :only => [:show]

      helper_method :search_action_url
    end

    def index
      @nav_li_active = 'explore'
      params[:per_page] = params[:per_page].presence || '50'
      (@response, @document_list) = search_service.search_results
      params[:view] ||= 'list' # still need this or grid view is invoked
      params[:sort] = 'title_info_primary_ssort asc'

      respond_to do |format|
        format.html
      end
    end

    def show
      @nav_li_active = 'explore'
      @show_response, @document = search_service.fetch(params[:id])
      @institution_title = @document[blacklight_config.index.title_field.to_sym]

      # get the response for collection objects
      collex_f_params = {blacklight_config.index.display_type_field => 'Collection',
                         'institution_pid_ssi' => params[:id]}
      @collex_response, @collex_documents = search_service.search_results({:f => collex_f_params,
                                                            :rows => 500,
                                                            :sort => 'title_info_primary_ssort asc'})

      # add params[:f] for proper facet links
      params[:f] = {blacklight_config.institution_field => [@institution_title]}

      # get the response for the facets representing items in collection
      (@response, @document_list) = search_service.search_results({:f => params[:f]})

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
