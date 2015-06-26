# returns preview (thumbnail) and full-size JPEG images
class PreviewController < CatalogController

  # give Preview access to useful BL/Solr methods
  include Blacklight::Configurable
  include Blacklight::SearchHelper

  copy_blacklight_config_from(CatalogController)

  # return an image file for <mods:url access='preview'> requests
  # for flagged items, return the image icon
  def preview
    solr_response, solr_document = fetch(params[:id])
    if solr_document[:exemplary_image_ssi]
      filename = solr_document[:id].to_s + '_thumbnail'
      if solr_document[blacklight_config.flagged_field.to_sym]
        send_icon(filename)
      else
        thumb_datastream_url = view_context.datastream_disseminator_url(solr_document[:exemplary_image_ssi], 'thumbnail300')
        @response = Typhoeus::Request.get(thumb_datastream_url)
        if response.headers[/404 Not Found/]
          not_found
        else
          send_image(filename)
        end
      end
    else
      not_found
    end
  end

  # return a full-size JPEG image file for 'full' requests
  # for flagged items, return the image icon
  def full
    solr_response, solr_document = fetch(params[:id])
    if solr_document[:exemplary_image_ssi]
      filename = solr_document[:id].to_s + '_full'
      if solr_document[blacklight_config.flagged_field.to_sym]
        send_icon(filename)
      else
        iiif_request_url = "#{IIIF_SERVER['url']}#{solr_document[:exemplary_image_ssi]}/full/full/0/default.jpg"
        @response = Typhoeus::Request.get(iiif_request_url)
        if @response.headers[/404 Not Found/]
          not_found
        else
          send_image(filename)
        end
      end
    else
      not_found
    end
  end

  # return a large-size JPEG image file for 'large' requests
  # for flagged items, return the image icon
  def large
    solr_response, solr_document = fetch(params[:id])
    if solr_document[:exemplary_image_ssi]
      filename = solr_document[:id].to_s + '_large'
      if solr_document[blacklight_config.flagged_field.to_sym]
        send_icon(filename)
      else
        access800_datastream_url = view_context.datastream_disseminator_url(solr_document[:exemplary_image_ssi], 'access800')
        #iiif_request_url = "#{IIIF_SERVER['url']}#{solr_document[:exemplary_image_ssi]}/full/,800/0/default.jpg"
        @response = Typhoeus::Request.get(access800_datastream_url)
        if @response.headers[/404 Not Found/]
          not_found
        else
          send_image(filename)
        end
      end
    else
      not_found
    end
  end

  private

  def not_found
    raise ActionController::RoutingError.new('Not Found')
  end

  def send_icon(filename)
    send_file File.join(Rails.root, 'app', 'assets', 'images', 'dc_image-icon.png'),
              :filename => filename + '.png',
              :type => :png,
              :disposition => 'inline'
  end

  def send_image(filename)
    send_data @response.body,
              :filename => filename + '.jpg',
              :type => :jpg,
              :disposition => 'inline'
  end


end
