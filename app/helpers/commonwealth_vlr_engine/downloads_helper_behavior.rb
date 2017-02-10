module CommonwealthVlrEngine
  module DownloadsHelperBehavior

    # create an array of download links
    # images have to be handled by a separate function since there are multiple sizes
    def create_download_links(document, files_hash)
      download_links = []
      non_img_file_types = [files_hash[:audio], files_hash[:documents], files_hash[:ereader], files_hash[:generic]]
      if has_downloadable_images?(document, files_hash) && !files_hash[:images].empty?
        download_links.concat(image_download_links(document, files_hash[:images]))
      end
      non_img_file_types.each do |file_type|
        file_type.each do |file|
          object_profile_json = JSON.parse(file['object_profile_ssm'].first)
          download_links << file_download_link(file['id'],
                                               download_link_title(document, object_profile_json),
                                               object_profile_json,
                                               'productionMaster',
                                               download_link_options)
        end
      end
      download_links
    end

    def download_link_class
      'sidebar_downloads_link'
    end

    def download_link_options
      {class: download_link_class, rel: 'nofollow', data: {:ajax_modal => 'trigger'}}
    end

    def download_link_title(document, object_profile, datastream_id=nil)
      if !object_profile || (document[:has_model_ssim].include? "info:fedora/afmodel:Bplmodels_ImageFile")
        link_title = t("blacklight.downloads.images.#{datastream_id}")
      else
        file_name_ext = object_profile["objLabel"].split('.')
        if document[:identifier_ia_id_ssi] || (document[:active_fedora_model_ssi] == "Bplmodels::EreaderFile")
          link_title = ia_download_title(file_name_ext[1])
        else
          link_title = file_name_ext[0]
        end
      end
      link_title
    end

    def has_downloadable_files?(document, files_hash)
      has_downloadable_images?(document, files_hash) ||
          files_hash[:documents].present? ||
          files_hash[:audio].present? ||
          files_hash[:generic].present? ||
          files_hash[:ereader].present?
    end

    def has_downloadable_images?(document, files_hash)
      has_image_files?(files_hash) && license_allows_download?(document)
    end

    # render the file type names for Internet Archive book item download links
    def ia_download_title(file_extension)
      case file_extension
        when 'mobi'
          'Kindle'
        when 'zip'
          'Daisy'
        else
          file_extension.upcase
      end
    end

    def image_datastreams(object_profile_json)
      image_datastreams = []
      stored_datastreams = %w(productionMaster access800 georectifiedMaster)
      stored_datastreams.each do |datastream_id|
        image_datastreams << datastream_id unless object_profile_json["datastreams"][datastream_id].blank?
      end
      image_datastreams.insert(1, 'accessFull')
    end

    def image_download_links(document, image_files_hash)
      if document[:identifier_ia_id_ssi]
        [file_download_link(document[:id],
                            t("blacklight.downloads.images.accessFull"),
                            nil,
                            'JPEG2000',
                            download_link_options)]
      else
        object_profile_json = JSON.parse(image_files_hash.first['object_profile_ssm'].first)
        image_links = []
        image_datastreams(object_profile_json).each do |datastream_id|
          if image_files_hash.length == 1
            object_profile = object_profile_json
            object_id = image_files_hash.first['id']
          else
            object_profile = setup_zip_object_profile(image_files_hash, datastream_id)
            object_id = document[:id]
          end
          image_links << file_download_link(object_id,
                                            t("blacklight.downloads.images.#{datastream_id}"),
                                            object_profile,
                                            datastream_id,
                                            download_link_options)
        end
        image_links
      end
    end

    # parse the license statement and return true if image downloads are allowed
    def license_allows_download? document
      document[:license_ssm].to_s =~ /(Creative Commons|No known restrictions)/
    end

    def file_download_link(object_pid, link_title, object_profile_json, datastream_id, link_options={})
      link_to(link_title,
              download_path(object_pid, datastream_id: datastream_id),
              link_options) + content_tag(:span,
                                          "(#{file_type_string(datastream_id, object_profile_json)}, #{file_size_string(datastream_id, object_profile_json)})",
                                          class: 'download_info')
    end

    def file_type_string(datastream_id, object_profile_json)
      if object_profile_json
        if datastream_id == 'accessFull' || datastream_id == 'access800'
          file_type_string = 'JPEG'
        else
          #file_type_string = object_profile_json["datastreams"][datastream_id]["dsMIME"].split('/')[1].upcase
          file_type_string = object_profile_json["objLabel"].split('.')[1].upcase
        end
        file_type_string << ', multi-file ZIP' if object_profile_json["zip"]
      else
        file_type_string = case datastream_id
                             when 'productionMaster'
                               'TIF'
                             when 'JPEG2000'
                               datastream_id
                             else
                               'JPEG'
                           end
      end
      file_type_string
    end

    def file_size_string(datastream_id, object_profile_json)
      if object_profile_json
        if datastream_id == 'accessFull'
          file_size_string = '~' +
              number_to_human_size((object_profile_json["datastreams"]["productionMaster"]["dsSize"] * 0.083969078))
        else
          file_size_string = number_to_human_size(object_profile_json["datastreams"][datastream_id]["dsSize"])
          file_size_string.insert(0,'~') if object_profile_json["zip"]
        end
      else
        file_size_string = 'multi-file ZIP'
      end
      file_size_string
    end

    # create a composite object_profile_json object from multiple file objects
    # used to display size of ZIP archive
    def setup_zip_object_profile(image_files_hash, datastream_id)
      datastream_id_to_use = datastream_id == 'accessFull' ? 'productionMaster' : datastream_id
      object_profile = {zip: true,
                        objLabel: datastream_id == 'productionMaster' ? '.TIF' : '.JPEG',
                        datastreams: {datastream_id_to_use.to_sym => {}}}
      zip_size = 0
      image_files_hash.each do |image_file|
        img_object_profile_json = JSON.parse(image_file['object_profile_ssm'].first)
        zip_size += img_object_profile_json["datastreams"][datastream_id_to_use]["dsSize"]
      end
      # estimate compression, pretty rough
      zip_size = case datastream_id
                   when 'productionMaster'
                     zip_size * 0.798
                   when 'accessFull'
                     zip_size * 0.839
                   else
                     zip_size * 0.927
                 end
      object_profile[:datastreams][datastream_id_to_use.to_sym][:dsSize] = zip_size
      object_profile.deep_stringify_keys
    end

    def url_for_download(document, datastream_id)
      if document[:identifier_ia_id_ssi] && datastream_id == 'JPEG2000'
        "https://archive.org/download/#{document[:identifier_ia_id_ssi]}/#{document[:identifier_ia_id_ssi]}_jp2.zip"
      else
        trigger_downloads_path(document.id, datastream_id: datastream_id)
      end
    end

  end
end