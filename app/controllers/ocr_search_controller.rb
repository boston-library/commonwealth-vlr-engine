class OcrSearchController < CatalogController

  ##
  # access to the CatalogController configuration
  include Blacklight::Configurable
  include Blacklight::SearchHelper
  include CommonwealthVlrEngine::CatalogHelper

  copy_blacklight_config_from(CatalogController)

  before_filter :modify_config_for_ocr, :only => [:index]
  before_filter :modify_search_params_logic_for_ocr, :only => [:index]

  def index
    @doc_response, @document = fetch(params[:id])
    if params[:ocr_q]
      @image_pid_list = has_image_files?(get_files(params[:id]))
      ocr_search_params = {q: {"is_file_of_ssim" => "info:fedora/#{params[:id]}",
                               blacklight_config.ocr_search_field => params[:ocr_q]}}
      ocr_search_params[:page] = params[:page] if params[:page]
      ocr_search_params[:sort] = params[:sort] if params[:sort]
      # for some reason, have to set :fl here, or gets scrubbed out of ocr_search_params somehow
      blacklight_config.default_solr_params[:fl] =
          "id,#{blacklight_config.page_num_field},#{termfreq_query(params[:ocr_q])}"
      (@response, @document_list) = search_results(ocr_search_params, search_params_logic)
    else
      (@response, @document_list) = {},[]
    end

    respond_to do |format|
      # Draw the facet selector for users who have javascript disabled:
      format.html
      # Draw the partial for the ocr search results modal window:
      format.js { render :layout => false }
    end
  end

  private

  # modify Solr query/response for OCR searches
  def modify_config_for_ocr
    blacklight_config.sort_fields = {}
    blacklight_config.add_sort_field 'score desc, system_create_dtsi asc', label: 'relevance'
    blacklight_config.add_sort_field 'system_create_dtsi asc', label: 'page #'
    blacklight_config.add_facet_fields_to_solr_request = false
    blacklight_config.add_index_field blacklight_config.ocr_search_field,
                                      highlight: true,
                                      helper_method: 'render_ocr_snippets'
    blacklight_config.default_per_page = 5
  end

  # modify Solr search_params_logic for OCR searches
  def modify_search_params_logic_for_ocr
    self.search_params_logic -= [:exclude_unwanted_models, :institution_limit]
    self.search_params_logic += [:ocr_search_params] unless self.search_params_logic.include?(:ocr_search_params)
  end

  # create the Solr function query to return term frequency
  def termfreq_query(ocr_search_terms)
    search_terms = ocr_search_terms.split(' ')
    if search_terms.length == 1
      "term_freq:termfreq(#{blacklight_config.ocr_search_field},\"#{ocr_search_terms}\")"
    else
      termfreq_array = search_terms.map { |v| "termfreq(#{blacklight_config.ocr_search_field},\"#{v}\")" }
      "term_freq:sum(#{termfreq_array.join(',')})"
    end
  end

  # don't add OCR searches to Blacklight's search history/session
  def start_new_search_session?
    false
  end

end