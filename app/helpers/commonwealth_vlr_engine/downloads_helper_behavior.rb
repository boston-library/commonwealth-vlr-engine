module CommonwealthVlrEngine
  module DownloadsHelperBehavior

    def create_download_links(document, files_hash)
      other_file_types = [files_hash[:audio], files_hash[:documents], files_hash[:ereader], files_hash[:generic]]
      download_links = []
      download_links.concat(image_download_links(document, files_hash[:images])) if files_hash[:images]
      other_file_types.each do |file_type|
        file_type.each do |file|
          object_profile_json = JSON.parse(file['object_profile_ssm'].first)
          file_name_ext = object_profile_json["objLabel"].split('.')
          download_link_title = document['identifier_ia_id_ssi'] ? ia_download_title(file_name_ext[1]) : file_name_ext[0]
          download_links << file_download_link(file['id'],
                                                      download_link_title,
                                                      object_profile_json,
                                                      'productionMaster')
        end
      end
      download_links
    end

    def download_link_class
      'sidebar_downloads_link'
    end

    def has_downloadable_files? document, files_hash
      has_downloadable_images?(document, files_hash) ||
          files_hash[:documents].present? ||
          files_hash[:audio].present? ||
          files_hash[:generic].present? ||
          files_hash[:ereader].present?
    end

    def has_downloadable_images? document, files_hash
      has_image_files?(files_hash) && license_allows_download?(document)
    end

    # render the file type names for Internet Archive book item download links
    def ia_download_title(file_extension)
      case file_extension
        when 'mobi'
          'Kindle'
        when 'zip'
          'Daisy'
        when 'pdf'
          'PDF'
        when 'epub'
          'EPUB'
        else
          file_extension.upcase
      end
    end

    # create a link to the JP2 zip download at Internet Archive
    def ia_zip_download_link(ia_identifier)
      render_download_link(t('blacklight.downloads.images.ia_zip.title'),
                           "https://archive.org/download/#{ia_identifier}/#{ia_identifier}_jp2.zip",
                           "(#{t('blacklight.downloads.images.ia_zip.info')})")
    end

    def image_datastreams
      %w(productionMaster accessFull access800)
    end

    def image_download_links(document, image_files_hash)
      if document[:identifier_ia_id_ssi]
        [ia_zip_download_link(document[:identifier_ia_id_ssi])]
      else
        object_profile_json = JSON.parse(image_files_hash.first['object_profile_ssm'].first)
        image_links = []
        image_datastreams.each do |datastream_id|
          if image_files_hash.length == 1
            image_links << file_download_link(image_files_hash.first['id'],
                                              t("blacklight.downloads.images.#{datastream_id}"),
                                              object_profile_json,
                                              datastream_id)
          else
            image_links << multifile_download_link(document[:id],
                                                   t("blacklight.downloads.images.#{datastream_id}"),
                                                   object_profile_json,
                                                   datastream_id)
          end
        end
        image_links
      end
    end

    # parse the license statement and return true if image downloads are allowed
    def license_allows_download? document
      document[:license_ssm].to_s =~ /Creative Commons/ || document[:license_ssm].to_s =~ /No known restrictions/
    end

    def render_download_link(link_title, link_path, span_content)
      link_to(link_title,
              link_path,
              target: '_blank',
              rel: 'nofollow',
              class: download_link_class) + content_tag(:span,
                                                        span_content,
                                                        class: 'download_info')
    end

    def file_download_link(file_pid, link_title, object_profile_json, datastream_id)
      if datastream_id == 'accessFull'
        file_type = 'JPEG'
        file_size = '~' +
            number_to_human_size((object_profile_json["datastreams"]["productionMaster"]["dsSize"].to_i * 0.083969078).to_i.to_s)
      else
        file_type = object_profile_json["datastreams"][datastream_id]["dsMIME"].split('/')[1].upcase
        file_size = number_to_human_size(object_profile_json["datastreams"][datastream_id]["dsSize"])
      end
      render_download_link(link_title,
                           download_path(file_pid, datastream_id: datastream_id),
                           "(#{file_type}, #{file_size})")
    end

    def multifile_download_link(object_pid, link_title, object_profile_json, datastream_id)
      file_type = datastream_id == 'productionMaster' ? 'TIFF' : 'JPEG'
      render_download_link(link_title, 
                           download_path(object_pid, datastream_id: datastream_id),
                           "(#{file_type}, ZIP)")
    end

  end
end