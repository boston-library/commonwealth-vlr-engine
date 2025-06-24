# frozen_string_literal: true

# use to render new image in multi image viewer in catalog#show
class ImageViewerController < CatalogController
  include CommonwealthVlrEngine::CatalogHelperBehavior

  # TODO: currently unused, since we are now using a multi-image Openseadragon viewer
  #       may need to redirect this to catalog#show for legacy URLs?
  def show
    @document = search_service.fetch(params[:id])
    @title = @document[blacklight_config.index.title_field.field]
    # @object_files is already set by before_action in CommonwealthVlrEngine::ControllerOverride
    @page_sequence = create_img_sequence(@object_files[:image], params[:view])
    respond_to do |format|
      format.js
      format.html { redirect_to solr_document_path(@document.id, view: params[:view]) }
    end
  end

  # TODO: currently unused, since we are now embedding the Universal Viewer in the catalog#show
  #       view via CommonwealthVlrEngine::Media::BookViewerComponent, but we may need to
  #       maintain this action and redirect to catalog#show for legacy URLs?
  def book_viewer
    @document = search_service.fetch(params[:id])

    respond_to do |format|
      format.html { render layout: 'book_viewer' }
    end
  end
end
