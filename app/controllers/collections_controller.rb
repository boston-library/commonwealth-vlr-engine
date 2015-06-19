class CollectionsController < CatalogController

  ##
  # Give Bookmarks access to the CatalogController configuration
  include Blacklight::Configurable
  include Blacklight::SearchHelper

  copy_blacklight_config_from(CatalogController)

  # show series facet for collections#show
  configure_blacklight do |config|
    series_facet = config.facet_fields["related_item_series_ssim"]
    series_facet.show = true
    series_facet.if = true # have to include this or it won't display!
    series_facet.limit = 300
    series_facet.sort = 'index'
    series_facet.include_in_request = true
  end

  # Blacklight uses #search_action_url to figure out the right URL for
  # the global search box
  def search_action_url options = {}
    catalog_index_url(options.except(:controller, :action))
  end
  helper_method :search_action_url

  def index
    @nav_li_active = 'explore'
    self.search_params_logic += [:collections_filter]
    (@response, @document_list) = search_results(params, search_params_logic)
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
    (@response, @document_list) = search_results({:f => params[:f]}, search_params_logic)

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

  private

  # find the title and pid for the object representing the collection image
  def get_collection_image_info(image_pid, collection_pid)
    col_img_info = {title: '', pid: collection_pid, access_master: false}
    col_img_file_doc = fetch(image_pid)[1]
    if col_img_file_doc
      col_img_info[:access_master] = true if col_img_file_doc[:is_image_of_ssim]
      col_img_field = col_img_file_doc[:is_image_of_ssim].presence || col_img_file_doc[:is_file_of_ssim].presence
      if col_img_field
        col_img_obj_pid = col_img_field.first.gsub(/info:fedora\//,'')
        col_img_obj_doc = fetch(col_img_obj_pid)[1]
        if col_img_obj_doc
          col_img_info[:title] = col_img_obj_doc[blacklight_config.index.title_field.to_sym]
          col_img_info[:pid] = col_img_obj_pid
        end
      end
    end
    col_img_info
  end

  # find a representative image for a series
  # TODO better exception handling for items which don't have exemplary_image
  def get_series_image_obj(series_title,collection_title)
    self.search_params_logic += [:flagged_filter]
    series_doc_list = search_results(
        {:f => {'related_item_series_ssim' => series_title,
                blacklight_config.collection_field => collection_title},
         :rows => 1},
        search_params_logic)[1]
    series_doc_list.first
  end
  helper_method :get_series_image_obj

  # set the correct facet params for facets from the collection
  def set_collection_facet_params(collection_title, document)
    facet_params = {blacklight_config.collection_field => [collection_title]}
    facet_params[blacklight_config.institution_field] = document[blacklight_config.institution_field.to_sym] if t('blacklight.home.browse.institutions.enabled')
    facet_params
  end

  # Not using this for now
  # find a representative image for a collection if none is assigned
  # TODO better exception handling for items which don't have exemplary_image
  #def get_collection_image_pid(collection_title)
  #  (@default_coll_img_resp, @default_coll_img_doc_list) = search_results(
  #      {:f => {blacklight_config.collection_field => collection_title,
  #              'has_model_ssim' => 'info:fedora/afmodel:Bplmodels_ObjectBase'},
  #       :rows => 1
  #      })
  #  @default_coll_img_doc_list.first[:exemplary_image_ssi]
  #end
  #helper_method :get_collection_image_pid

end
