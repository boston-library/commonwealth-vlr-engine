module CommonwealthVlrEngine
  module InstitutionsControllerBehavior
    extend ActiveSupport::Concern
    ##
    # Give Bookmarks access to the CatalogController configuration
    include Blacklight::Configurable
    include Blacklight::SearchHelper

    included do
      copy_blacklight_config_from(CatalogController)

      before_filter :institutions_index_config, :only => [:index]
      # remove collection facet and collapse others
      before_filter :relation_base_blacklight_config, :only => [:show]
    end

    def index
      @nav_li_active = 'explore'
      params[:per_page] = params[:per_page].presence || '50'
      (@response, @document_list) = search_results(params)
      params[:view] ||= 'list' # still need this or grid view is invoked
      params[:sort] = 'title_info_primary_ssort asc'

      respond_to do |format|
        format.html
      end
    end

    def show
      @nav_li_active = 'explore'
      @show_response, @document = fetch(params[:id])
      @institution_title = @document[blacklight_config.index.title_field.to_sym]

      # get the response for collection objects
      @collex_response, @collex_documents = search_results({:f => {'active_fedora_model_suffix_ssi' => 'Collection','institution_pid_ssi' => params[:id]},:rows => 100, :sort => 'title_info_primary_ssort asc'})

      # add params[:f] for proper facet links
      params[:f] = {blacklight_config.institution_field => [@institution_title]}

      # get the response for the facets representing items in collection
      (@response, @document_list) = search_results({:f => params[:f]})

      respond_to do |format|
        format.html
      end

    end

    def range_limit
      redirect_to range_limit_catalog_path(params) and return
    end

    protected

    # remove grid view from blacklight_config, use correct SearchBuilder for index view
    def institutions_index_config
      blacklight_config.search_builder_class = CommonwealthInstitutionsSearchBuilder
      blacklight_config.view.delete(:gallery)
      blacklight_config.view.delete(:masonry)
      blacklight_config.view.delete(:slideshow)
    end
  end
end