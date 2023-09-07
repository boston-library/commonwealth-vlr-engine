# frozen_string_literal: true

class ZipDownloadsController < ApplicationController
  include CommonwealthVlrEngine::DownloadsControllerBehavior
  include Zipline

  # initiates the zip file download
  def trigger_download
    not_found unless verify_recaptcha

    @solr_document = SolrDocument.find(params[:id])

    if @solr_document[:curator_model_ssi] == 'Curator::DigitalObject' && params[:filestream_id].present?
      @file_list = get_image_files(params[:id])
      not_found if @file_list.empty?

      @object_id = params[:id]
      send_zipped_content
    else
      not_found
    end
  end

  protected

  # send multiple files as a zip archive
  def send_zipped_content
    files_array = []
    @file_list.each_with_index do |file, index|
      params[:id] = file[:id] # so #file_url returns correct value
      @attachments = JSON.parse(file[:attachments_ss])
      files_array << [file_url, "#{(index + 1)}_#{file_name_with_extension(file)}"]
    end
    zipline(files_array, "#{file_name}.zip")
  end
end
