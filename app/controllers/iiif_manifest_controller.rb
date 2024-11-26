# frozen_string_literal: true

# use to render new image in multi image viewer in catalog#show
class IiifManifestController < CatalogController
  include CommonwealthVlrEngine::CatalogHelperBehavior
  include CommonwealthVlrEngine::IiifManifest

  skip_before_action :verify_authenticity_token, only: [:cache_invalidate]
  after_action :set_access_control_headers, only: [:manifest, :canvas, :annotation]

  def manifest
    image_files = get_image_files(params[:id])
    if image_files.length > 0
      @iiif_manifest = Rails.cache.fetch(params[:id],
                                         { namespace: cache_namespace, compress: true }) do
        document = search_service.fetch(params[:id])
        create_iiif_manifest(document, image_files).to_json
      end
      render json: @iiif_manifest
    else
      not_found
    end
  end

  def canvas
    canvas_document = search_service.fetch(params[:canvas_object_id])
    if canvas_document[:is_file_set_of_ssim]
      document = search_service.fetch(params[:id])
      image_files = image_file_pids(get_image_files(params[:id]))
      if image_files
        image_index = Hash[image_files.map.with_index.to_a][params[:canvas_object_id]]
        iiif_canvas = canvas_from_id(params[:canvas_object_id],
                                     label_for_canvas(canvas_document, image_index),
                                     document)
        render json: iiif_canvas.to_json
      else
        not_found
      end
    else
      not_found
    end
  end

  def annotation
    document = search_service.fetch(params[:id])
    if image_file_pids(get_image_files(params[:id])).include?(params[:annotation_object_id])
      annotation = image_annotation_from_image_id(params[:annotation_object_id], document)
      render json: annotation.to_json
    else
      not_found
    end
  end

  # delete the cached manifest
  def cache_invalidate
    result = Rails.cache.delete(params[:id], { namespace: cache_namespace }) ? true : false
    status = result ? :ok : :not_found
    render json: { result: result }.as_json, status: status
  end

  private

  # to allow apps to load manifest JSON received from a remote server
  def set_access_control_headers
    headers['Access-Control-Allow-Origin'] = '*'
  end

  def cache_namespace
    'manifest'
  end
end
