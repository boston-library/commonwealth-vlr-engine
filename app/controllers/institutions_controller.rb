class InstitutionsController < CatalogController

  ##
  # Give Bookmarks access to the CatalogController configuration
  include Blacklight::Configurable
  include Blacklight::SearchHelper

  copy_blacklight_config_from(CatalogController)

  before_filter :institutions_index_config, :only => [:index]
  # remove collection facet and collapse others
  before_filter :relation_base_blacklight_config, :only => [:show]

  # Blacklight uses #search_action_url to figure out the right URL for
  # the global search box
  def search_action_url options = {}
    search_catalog_url(options.except(:controller, :action))
  end
  helper_method :search_action_url

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

    # get an image for the institution
    if @document[:exemplary_image_ssi]
      @institution_image_pid = @document[:exemplary_image_ssi]
    end

    respond_to do |format|
      format.html
    end

  end

  private

  # remove grid view from blacklight_config, use correct SearchBuilder for index view
  def institutions_index_config
    blacklight_config.search_builder_class = CommonwealthInstitutionsSearchBuilder
    blacklight_config.view.delete(:gallery)
    blacklight_config.view.delete(:masonry)
    blacklight_config.view.delete(:slideshow)
  end

end