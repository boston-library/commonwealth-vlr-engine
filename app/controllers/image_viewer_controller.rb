# frozen_string_literal: true

# use to render new image in multi image viewer in catalog#show
class ImageViewerController < CatalogController
  # include CommonwealthVlrEngine::CatalogHelperBehavior

  # TODO: DEPRECATED, since we are now using a multi-image Openseadragon viewer
  #       in catalog#show view via CommonwealthVlrEngine::Media::MultiImageViewerComponent,
  #       but keep for the moment in case we need it later
  # def show
  #   @document = search_service.fetch(params[:id])
  #   @title = @document[blacklight_config.index.title_field.field]
  #   # @object_files is already set by before_action in CommonwealthVlrEngine::ControllerOverride
  #   @page_sequence = create_img_sequence(@object_files[:image], params[:view])
  #   respond_to do |format|
  #     format.js
  #     format.html { redirect_to solr_document_path(@document.id, view: params[:view]) }
  #   end
  # end

  # TODO: DEPRECATED, since we are now embedding Universal Viewer
  #       in catalog#show view via CommonwealthVlrEngine::Media::BookViewerComponent,
  #       but keep for the moment in case we need it later
  # def book_viewer
  #   @document = search_service.fetch(params[:id])
  #
  #   respond_to do |format|
  #     format.html { render layout: 'book_viewer' }
  #   end
  # end
end
