module CommonwealthVlrEngine
  module DownloadsControllerBehavior
    extend ActiveSupport::Concern

    include CommonwealthVlrEngine::ApplicationHelper

    def show
      #response, document = fetch(params[:id])
      image_files = get_image_files(params[:id])
      unless image_files.empty?
        if image_files.length == 1
          #puts "IMAGE_FILES = " + image_files.inspect
          datastream_url = image_url(image_files.first['id'], params[:size])
          extension = file_extension(params[:size], image_files.first['mime_type_tesim'])
          puts "DTSMURL = " + datastream_url.inspect
        else
          # multiple images
        end
        response = Typhoeus::Request.get(datastream_url)
        if response.code == 404
          not_found
        else
          send_image(params[:id], response.body, extension)
        end

      end

    end

    private

    def file_extension(size, mime_type)
      case size
        when 'master'
          mime_type.gsub(/\A[\w]*\//,'')
        else
          'jpg'
      end
    end

    # returns a Fedora datastream url or IIIF url
    def image_url(pid, size)
      case size
        when 'full'
          iiif_image_url(pid, {})
        when 'master'
          datastream_disseminator_url(pid, 'productionMaster')
        else
          datastream_disseminator_url(pid, 'access800')
      end
    end

    def send_image(filename, binary, extension)
      send_data binary,
                :filename => "#{filename}.#{extension}",
                :type => extension.to_sym,
                :disposition => 'attachment'
    end

  end
end
