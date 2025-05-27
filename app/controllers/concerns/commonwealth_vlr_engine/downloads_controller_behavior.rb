# frozen_string_literal: true

# heavily based on Hydra::Controller::DownloadBehavior
module CommonwealthVlrEngine
  module DownloadsControllerBehavior
    extend ActiveSupport::Concern

    include Blacklight::Catalog
    include CommonwealthVlrEngine::Streaming
    include CommonwealthVlrEngine::ApplicationHelper
    include CommonwealthVlrEngine::Finder

    included do
      copy_blacklight_config_from(CatalogController)
      helper_method :search_action_url
    end

    protected

    # TODO: maybe remove this? The default implementation in Blacklight is more context-aware,
    # this method is used for "remove" facet links, but maybe also for header search URL?
    # def search_action_url options = {}
    #   options = options.to_h if options.is_a? Blacklight::SearchState
    #   url_for(options.reverse_merge(action: 'index'))
    # end

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

    def file_name(solr_document = @solr_document)
      ids = %w(other accession barcode)
      id_val = nil
      ids.each do |id|
        next if id_val

        id_val = solr_document["identifier_local_#{id}_tsim".to_sym]&.first
      end

      file_name_base = id_val || solr_document[:filename_base_ssi] || solr_document[:id]
      "#{file_name_base.gsub(/[\s:]/, '')}_#{params[:filestream_id]}"
    end

    def file_name_with_extension(solr_document = @solr_document)
      "#{file_name(solr_document)}.#{file_extension}"
    end

    def file_size
      return false if params[:filestream_id] == 'image_access_full'

      @attachments[params[:filestream_id]]['byte_size']
    end

    def mime_type
      @attachments.dig(params[:filestream_id], 'content_type') || 'image/jpeg'
    end

    def prepare_file_headers
      response.headers['Content-Disposition'] = ActionDispatch::Http::ContentDisposition.format(disposition: 'attachment',
                                                                                                filename: file_name_with_extension)
      response.headers['Content-Type'] = mime_type
      response.headers['Content-Length'] = file_size.to_s if file_size
      # Prevent Rack::ETag from calculating a digest over body
      response.headers['Last-Modified'] = Time.parse(@solr_document[:system_modified_dtsi]).utc.strftime('%a, %d %b %Y %T GMT')
      response.headers['X-Accel-Buffering'] = 'no'
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
