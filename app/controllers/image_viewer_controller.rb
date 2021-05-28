# frozen_string_literal: true

# use to render new image in multi image viewer in catalog#show
class ImageViewerController < CatalogController
  include CommonwealthVlrEngine::CatalogHelperBehavior

  def show
    _response, @document = search_service.fetch(params[:id])
    @title = @document[blacklight_config.index.title_field.to_sym]
    # @object_files is already set by before_action in CommonwealthVlrEngine::ControllerOverride
    @page_sequence = create_img_sequence(@object_files[:image], params[:view])
    respond_to do |format|
      format.js
      format.html { redirect_to solr_document_path(@document.id, view: params[:view]) }
    end
  end

  def book_viewer
    _response, @document = search_service.fetch(params[:id])

    respond_to do |format|
      format.html { render layout: 'book_viewer' }
    end
  end
end
