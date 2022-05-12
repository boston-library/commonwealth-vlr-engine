# frozen_string_literal: true

# heavily based on Hydra::Controller::DownloadBehavior
module CommonwealthVlrEngine
  module DownloadsControllerBehavior
    extend ActiveSupport::Concern

    include Blacklight::Catalog
    include CommonwealthVlrEngine::Streaming
    include CommonwealthVlrEngine::ApplicationHelper
    include CommonwealthVlrEngine::Finder
    # for some reason have to require AND include Zipline, or you get errors
    require 'zipline'
    include Zipline
    require 'open-uri'

    included do
      copy_blacklight_config_from(CatalogController)
      helper_method :search_action_url
    end

    # render a page/modal with license terms, download links, etc
    def show
      @doc_response, @document = search_service.fetch(params[:id])
      if @document[:curator_model_ssi].include? 'Filestream'
        _parent_response, @parent_document = search_service.fetch(parent_id(@document))
        @object_profile = JSON.parse(@document['attachments_ss'])
      else
        @parent_document = @document
        @object_profile = nil
      end

      respond_to do |format|
        format.html do
          render layout: false if request.xhr?
        end # for users w/o JS
        format.js { render layout: false } # download modal window
      end
    end

    # initiates the file download
    def trigger_download
      _response, @solr_document = search_service.fetch(params[:id])
      return unless !@solr_document.to_h.empty? && params[:filestream_id]

      if @solr_document[:curator_model_ssi].include? 'Filestream'
        @object_id = parent_id(@solr_document)
        @attachments = JSON.parse(@solr_document[:attachments_ss])
        send_content
      elsif @solr_document[:curator_model_ssi] == 'Curator::DigitalObject'
        @file_list = get_image_files(params[:id])
        if !@file_list.empty?
          @object_id = params[:id]
          send_zipped_content
        else
          not_found
        end
      else
        not_found
      end
    end

    protected

    # Blacklight uses #search_action_url to figure out the right URL for
    # the global search box
    def search_action_url options = {}
      search_catalog_url(options.except(:controller, :action))
    end

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

    # send multiple files as a zip archive
    def send_zipped_content
      files_array = []
      @file_list.each_with_index do |file, index|
        params[:id] = file[:id] # so file_url returns correct value
        @solr_document = file
        @attachments = JSON.parse(@solr_document[:attachments_ss])
        files_array << [file_url, "#{(index + 1)}_#{file_name_with_extension}"]
      end
      file_mappings = files_array.lazy.map { |url, path| [open(url), path] }
      zipline(file_mappings, "#{file_name}.zip")
    end

    # render an HTTP HEAD response
    def content_head
      response.headers['Content-Length'] = file_size if file_size
      head :ok, content_type: mime_type
    end

    # Create some headers for the datastream
    def content_options
      { disposition: 'attachment', type: mime_type, filename: file_name_with_extension }
    end

    # returns a filestream url or IIIF url
    def file_url
      if params[:filestream_id] == 'image_access_full'
        iiif_image_url(params[:id], {})
      else
        filestream_disseminator_url(@attachments[params[:filestream_id]]['key'],
                                    params[:filestream_id], true)
      end
    end

    def file_extension
      @attachments.dig(params[:filestream_id], 'filename')&.split('.')&.last || 'jpg'
    end

    def file_name
      "#{@object_id.tr(':', '_')}_#{params[:filestream_id]}"
    end

    def file_name_with_extension
      "#{file_name}.#{file_extension}"
    end

    def file_size
      return false if params[:filestream_id] == 'image_access_full'

      @attachments[params[:filestream_id]]['byte_size']
    end

    def mime_type
      @attachments.dig(params[:filestream_id], 'content_type') || 'image/jpeg'
    end

    def prepare_file_headers
      send_file_headers! content_options
      response.headers['Content-Type'] = mime_type
      response.headers['Content-Length'] ||= file_size.to_s if file_size
      # Prevent Rack::ETag from calculating a digest over body
      response.headers['Last-Modified'] = Time.new(@solr_document[:system_modified_dtsi]).utc.strftime('%a, %d %b %Y %T GMT')
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
      response.headers['Content-Length'] = length.to_s
      self.status = 206
      prepare_file_headers
      stream_body file_stream(file_url, request.headers['HTTP_RANGE'])
    end

    private

    def parent_id(document)
      document[:is_file_set_of_ssim].first
    end

    def stream_body(iostream)
      iostream.each do |in_buff|
        response.stream.write in_buff
      end
    ensure
      response.stream.close
    end
  end
end
