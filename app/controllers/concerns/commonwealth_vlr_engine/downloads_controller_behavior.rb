# heavily based on Hydra::Controller::DownloadBehavior
module CommonwealthVlrEngine
  module DownloadsControllerBehavior
    extend ActiveSupport::Concern

    include Blacklight::Catalog
    include CommonwealthVlrEngine::Streaming
    include CommonwealthVlrEngine::ApplicationHelper

    # Responds to http requests to show the file
    def show
      solr_response, @solr_document = fetch(params[:id])
      if @solr_document[:has_model_ssim].include? 'info:fedora/afmodel:Bplmodels_File'
        send_content
      else
        not_found
      end
    end

    protected

    # Handle the HTTP show request
    def send_content
      response.headers['Accept-Ranges'] = 'bytes'
      if request.head?
        content_head
      elsif request.headers['HTTP_RANGE']
        send_range
      else
        send_file_contents
      end
    end

    # render an HTTP HEAD response
    def content_head
      response.headers['Content-Length'] = file_size if file_size
      head :ok, content_type: mime_type
    end

    # Create some headers for the datastream
    def content_options
      { disposition: 'attachment', type: mime_type, filename: file_name }
    end

    # returns a Fedora datastream url or IIIF url
    def file_url
      if params[:datastream_id] == 'accessFull'
        iiif_image_url(params[:id], {})
      else
        datastream_disseminator_url(params[:id], params[:datastream_id])
      end
    end

    def file_extension
      if params[:datastream_id] == 'productionMaster'
        JSON.parse(@solr_document[:object_profile_ssm].first)["objLabel"].split('.')[1]
      else
        'jpg'
      end
    end

    # @return [String] the filename
    def file_name
      "#{params[:id]}_#{params[:datastream_id]}." + file_extension
    end

    def file_size
      if params[:datastream_id] == 'accessFull'
        return false
      else
        JSON.parse(@solr_document[:object_profile_ssm].first)["datastreams"][params[:datastream_id]]["dsSize"]
      end
    end

    def mime_type
      if params[:datastream_id] == 'productionMaster'
        @solr_document[:mime_type_tesim].first
      else
        'image/jpeg'
      end
    end

    def not_found
      raise ActionController::RoutingError.new('Not Found')
    end

    def prepare_file_headers
      send_file_headers! content_options
      response.headers['Content-Type'] = mime_type
      response.headers['Content-Length'] ||= file_size.to_s
      # Prevent Rack::ETag from calculating a digest over body
      response.headers['Last-Modified'] = Time.new(@solr_document[:system_modified_dtsi]).utc.strftime("%a, %d %b %Y %T GMT")
      self.content_type = mime_type
    end

    def send_file_contents
      self.status = 200
      prepare_file_headers
      stream_body file_stream(file_url)
    end

    # render an HTTP Range response
    def send_range
      _, range = request.headers['HTTP_RANGE'].split('bytes=')
      from, to = range.split('-').map(&:to_i)
      to = file_size.to_i - 1 unless to
      length = to - from + 1
      response.headers['Content-Range'] = "bytes #{from}-#{to}/#{file_size}"
      response.headers['Content-Length'] = "#{length}"
      self.status = 206
      prepare_file_headers
      stream_body file_stream(file_url, request.headers['HTTP_RANGE'])
    end

    private

    def stream_body(iostream)
      iostream.each do |in_buff|
        response.stream.write in_buff
      end
    ensure
      response.stream.close
    end

  end
end
