class OcrSearchController < CatalogController

  ##
  # access to the CatalogController configuration
  include Blacklight::Configurable
  include Blacklight::SearchHelper
  include CommonwealthVlrEngine::CatalogHelper

  copy_blacklight_config_from(CatalogController)

  before_filter :modify_config_for_ocr, :only => [:index]
  before_filter :modify_search_params_logic_for_ocr, :only => [:index]
  after_filter :restore_search_params_logic, :only => [:index]

  def index
    if params[:ocr_q]
      @image_pid_list = has_image_files?(get_files(params[:id]))
      ocr_search_params = {:q => {"is_file_of_ssim" => "info:fedora/#{params[:id]}",
                                  blacklight_config.ocr_search_field => params[:ocr_q]}}
      ocr_search_params[:page] = params[:page] if params[:page]
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
    blacklight_config.add_facet_fields_to_solr_request = false
    blacklight_config.add_index_field blacklight_config.ocr_search_field, :highlight => true
    blacklight_config.default_per_page = 10
  end

  # modify Solr search_params_logic for OCR searches
  def modify_search_params_logic_for_ocr
    @original_search_params_logic = CatalogController.search_params_logic.dup
    self.search_params_logic.delete_if { |v| [:exclude_unwanted_models, :institution_limit].include?(v) }
    self.search_params_logic += [:ocr_search_params]
  end

  # restore Solr search_params_logic to its original state
  # otherwise changes made by #modify_search_params_logic_for_ocr carry over to other controllers!
  def restore_search_params_logic
    CatalogController.search_params_logic = @original_search_params_logic
  end

  # don't add OCR searches to Blacklight's search history/session
  def start_new_search_session?
    false
  end

end