# use to render new image in multi image viewer in catalog#show
class ImageViewerController < CatalogController

  include CommonwealthVlrEngine::CatalogHelper

  def show
    @response, @document = search_service.fetch(params[:id])
    @title = @document[blacklight_config.index.title_field.to_sym]
    # @object_files is already set by before_action in CommonwealthVlrEngine::ControllerOverride
    @page_sequence = create_img_sequence(image_file_pids(@object_files[:images]), params[:view])
    respond_to do |format|
      format.js
      format.html { redirect_to solr_document_path(@document.id,
                                                   :view => params[:view]) }
    end
  end

  def book_viewer
    @response, @document = search_service.fetch(params[:id])
    @image_files = image_file_pids(get_image_files(params[:id]))
    render layout: 'book_viewer'
  end
end
