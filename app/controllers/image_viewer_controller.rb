# use to render new image in multi image viewer in catalog#show
class ImageViewerController < CatalogController

  include CommonwealthVlrEngine::CatalogHelper

  def show
    @response, @document = fetch(params[:id])
    #@img_to_show = params[:view]
    @title = @document[blacklight_config.index.title_field.to_sym]
    @page_sequence = get_page_sequence(@document.id, params[:view])
    respond_to do |format|
      format.js
      format.html { redirect_to catalog_path(@document.id,
                                             :view => params[:view]) }
    end
  end

  def book_viewer
    @response, @document = fetch(params[:id])
    @title = @document[blacklight_config.index.title_field.to_sym]
    @image_files = has_image_files?(get_files(params[:id]))
    render(:layout => 'book_viewer')
  end

  private

  def get_page_sequence(document_id, current_img_id)
    image_files = []
    get_image_files(document_id).each do |img_file|
      image_files << img_file['id']
    end
    create_img_sequence(image_files, current_img_id)
  end

end