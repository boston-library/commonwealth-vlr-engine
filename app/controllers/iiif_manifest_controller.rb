# use to render new image in multi image viewer in catalog#show
class IiifManifestController < CatalogController

  include CommonwealthVlrEngine::CatalogHelper
  include CommonwealthVlrEngine::IiifManifest

  def manifest
    response, document = fetch(params[:id])
    image_files = has_image_files?(get_files(params[:id]))
    if image_files
      iiif_manifest = create_iiif_manifest(document, image_files)
      render :json => iiif_manifest.to_json
    else
      not_found
    end
  end

  def canvas
    canvas_response, canvas_document = fetch(params[:canvas_object_id])
    if canvas_document[:is_file_of_ssim]
      response, document = fetch(params[:id])
      image_files = has_image_files?(get_files(params[:id]))
      if image_files
        image_index = Hash[image_files.map.with_index.to_a][params[:canvas_object_id]]
        iiif_canvas = canvas_from_id(params[:canvas_object_id],
                                     "image#{(image_index+1).to_s}",
                                     document)
        render :json => iiif_canvas.to_json
      else
        not_found
      end
    else
      not_found
    end
  end

  def annotation
    response, document = fetch(params[:id])
    if has_image_files?(get_files(params[:id])).include?(params[:annotation_object_id])
      annotation = image_annotation_from_image_id(params[:annotation_object_id], document)
      render :json => annotation.to_json
    else
      not_found
    end
  end

  after_action :set_access_control_headers, :only => [:manifest, :canvas, :annotation]

  private

  # to allow apps to load manifest JSON received from a remote server
  def set_access_control_headers
    headers['Access-Control-Allow-Origin'] = "*"
  end

  def not_found
    raise ActionController::RoutingError.new('Not Found')
  end


end