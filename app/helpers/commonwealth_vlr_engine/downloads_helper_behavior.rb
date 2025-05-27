# frozen_string_literal: true

module CommonwealthVlrEngine
  module DownloadsHelperBehavior
    def has_downloadable_files?(document, files_hash)
      !harvested_object?(document) && license_allows_download?(document) &&
      (has_image_files?(files_hash) || has_video_files?(files_hash) || has_audio_files?(files_hash) ||
       has_document_files?(files_hash) || has_ereader_files?(files_hash))
    end

    def has_downloadable_images?(document, files_hash)
      has_image_files?(files_hash) && license_allows_download?(document)
    end

    def has_downloadable_video?(document, files_hash)
      has_video_files?(files_hash) && license_allows_download?(document)
    end

    # parse the license statement and return true if image downloads are allowed
    def license_allows_download?(document)
      document[:license_ss] =~ /(Creative Commons|No known restrictions)/
    end

    def public_domain?(document)
      pubdom_regex = /[Pp]ublic domain/
      (document[:date_end_dtsi] && document[:date_end_dtsi][0..3].to_i < 1923) ||
        document[:rights_ss] =~ pubdom_regex ||
        document[:license_ss] =~ pubdom_regex ||
        document[:rightsstatement_ss] == 'No Copyright - United States'
    end

    def url_for_download(document, filestream_id)
      if document[:identifier_ia_id_ssi] && filestream_id == 'JPEG2000'
        "https://archive.org/download/#{document[:identifier_ia_id_ssi]}/#{document[:identifier_ia_id_ssi]}_jp2.zip"
      elsif document[blacklight_config.index.display_type_field] == 'DigitalObject'
        trigger_zip_downloads_path(document.id, filestream_id: filestream_id)
      else
        trigger_downloads_path(document.id, filestream_id: filestream_id)
      end
    end

    def download_link_title(document, attachments, filestream_id = nil)
      if !attachments || (document[blacklight_config.index.display_type_field] == 'Image')
        link_title = t("blacklight.downloads.images.#{filestream_id}")
      else
        primary_file_key = attachments.keys.find { |k| k.match?(/\A[^_]*_primary/) } ||
          attachments.keys.find { |k| k.match?(filestream_id) } ||
          attachments.keys.find { |k| !k.match?(/foxml/) }
        file_name_ext = attachments[primary_file_key]['filename'].split('.')
        if document[:identifier_ia_id_ssi] || (document[blacklight_config.index.display_type_field] == 'Ereader')
          link_title = ia_download_title(filestream_id, file_name_ext[1])
        else
          link_title = file_name_ext[0]
        end
      end
      link_title
    end

    # render the file type names for Internet Archive book item download links
    def ia_download_title(attachment_type, file_extension)
      case attachment_type
      when 'ebook_access_mobi'
        'Kindle'
      when 'ebook_access_daisy'
        'Daisy'
      else
        file_extension.upcase
      end
    end

    def file_type_string(filestream_id, attachments_json)
      if attachments_json && attachments_json[filestream_id]
        file_type_string = if filestream_id == 'image_access_full' || filestream_id == 'image_access_800'
                             'JPEG'
                           elsif filestream_id == 'audio_access'
                             'MP3'
                           elsif filestream_id == 'audio_primary'
                             'WAV'
                           elsif filestream_id == 'text_plain'
                             'TXT'
                           elsif attachments_json[filestream_id]['content_type']
                             attachments_json[filestream_id]['content_type'].split('/')[1].upcase
                           else
                             filename = attachments_json[filestream_id]['filename'] || attachments_json['filename']
                             filename.split('.')[1].upcase
                           end.gsub(/TIFF/, 'TIF')
      else
        file_type_string = case filestream_id
                           when 'image_primary'
                             'TIF'
                           when 'JPEG2000'
                             filestream_id
                           else
                             'JPEG'
                           end
      end
      file_type_string += ', multi-file ZIP' if attachments_json&.dig('zip').present?
      file_type_string
    end

    def file_size_string(filestream_id, attachments_json)
      if attachments_json
        if filestream_id == 'image_access_full'
          # estimate size of full JPEG based on image_primary or image_service size
          estimate_filestream = attachments_json['image_primary'] || attachments_json['image_service']
          number_to_human_size((estimate_filestream['byte_size'] * 0.083969078))
        elsif attachments_json[filestream_id]
          number_to_human_size(attachments_json[filestream_id]['byte_size'])
        else
          'file size unavailable'
        end
      else
        'multi-file ZIP'
      end
    end
  end
end
