module CommonwealthVlrEngine
  module Finder

    def repository
      Blacklight.default_index
    end

    def get_files(pid)
      return_hash = {}
      file_types = %i(images documents audio ereader video generic)
      file_types.each { |file_type| return_hash[file_type] = [] }

      solr_response = repository.search({ q: "is_file_of_ssim:\"info:fedora/#{pid}\"", rows: 5000 })

      solr_response.documents.each do |solr_doc|
        found_model = false
        (file_types - [:generic]).each do |file_type|
          if solr_doc['has_model_ssim'].include?("info:fedora/afmodel:Bplmodels_#{file_type.to_s.singularize.capitalize}File")
            return_hash[file_type] << solr_doc
            found_model = true
          end
        end
        return_hash[:generic] << solr_doc unless found_model
      end

      file_types.each do |file_type|
        return_hash[file_type] = sort_files(return_hash[file_type])
      end

      return_hash
    end


    def sort_files(file_list)
      return file_list if file_list.length <= 1

      preceding_key_final = nil

      ending_item_pid = nil
      next_item_pid = nil

      return_list = []
      file_list.each do |file|
        preceding_key = file.keys.select { |key| key.include?'preceding'}
        following_key = file.keys.select { |key| key.include?'following'}

        if following_key.blank?
          return_list.insert(0, file)
          preceding_key_final = preceding_key.first
          next_item_pid = file[preceding_key_final].first
        elsif preceding_key.blank?
          return_list.insert(-1, file)
          ending_item_pid  = "info:fedora/#{file['id']}"
        end
      end

      while next_item_pid != ending_item_pid
        next_item = file_list.select { |array| "info:fedora/#{array['id'].to_s}" == next_item_pid }.first
        return_list.insert(-2, next_item)
        next_item_pid = next_item[preceding_key_final].first.to_s
      end

      return_list
    end

    def get_volume_objects(pid)
      return_list = []
      volumes_list = []
      solr_response = repository.search({q: "is_volume_of_ssim:\"info\:fedora/#{pid.gsub(':', '\:')}\" AND has_model_ssim:\"info\:fedora/afmodel:Bplmodels_Volume\"", rows: 5000})

      solr_response.documents.each do |solr_object|
        volumes_list << solr_object
      end
      sort_files(volumes_list).each do |volume|
        volume_files = get_files(volume.id)
        return_list << {vol_doc: volume, vol_files: volume_files.except(:images)}
      end
      return_list
    end

    def get_image_files(pid)
      solr_response = repository.search({q: "is_image_of_ssim:\"info\:fedora/#{pid.gsub(':', '\:')}\" AND has_model_ssim:\"info\:fedora/afmodel:Bplmodels_ImageFile\"", rows: 5000})
      sort_files(solr_response.documents)
    end

    # TODO: DETERMINE IF ANY OF THE METHODS BELOW ARE USED ANYWHERE (no usage in commonwealth-vlr-engine)

    def get_audio_files(pid)
      solr_response = repository.search({q: "is_audio_of_ssim:\"info\:fedora/#{pid.gsub(':', '\:')} AND has_model_ssim:\"info\:fedora/afmodel:Bplmodels_AudioFile\"", rows: 5000})
      sort_files(solr_response.documents)
    end

    def get_document_files(pid)
      solr_response = repository.search({q: "is_document_of_ssim:\"info\:fedora/#{pid.gsub(':', '\:')}\" AND has_model_ssim:\"info\:fedora/afmodel:Bplmodels_DocumentFile\"", rows: 5000})
      sort_files(solr_response.documents)
    end

    def get_ereader_files(pid)
      solr_response = repository.search({q: "is_ereader_of_ssim:\"info\:fedora/#{pid.gsub(':', '\:')}\" AND has_model_ssim:\"info\:fedora/afmodel:Bplmodels_EreaderFile\"", rows: 5000})
      sort_files(solr_response.documents)
    end

    def get_video_files(pid)
      solr_response = repository.search({q: "is_video_of_ssim:\"info\:fedora/#{pid.gsub(':', '\:')}\" AND has_model_ssim:\"info\:fedora/afmodel:Bplmodels_VideoFile\"", rows: 5000})
      sort_files(solr_response.documents)
    end

    def get_first_volume_object(pid)
      solr_response = repository.search({q: "-is_following_volume_of_ssim:* AND is_volume_of_ssim:\"info\:fedora/#{pid.gsub(':', '\:')}\" AND has_model_ssim:\"info\:fedora/afmodel:Bplmodels_Volume\""})
      sort_files(solr_response.documents)
    end

    def get_first_image_file(pid)
      solr_response = repository.search({q: "-is_following_image_of_ssim:* AND is_image_of_ssim:\"info\:fedora/#{pid.gsub(':', '\:')}\" AND has_model_ssim:\"info\:fedora/afmodel:Bplmodels_ImageFile\""})
      solr_response.documents&.first
    end

    def get_first_audio_file(pid)
      solr_response = repository.search({q: "-is_following_audio_of_ssim:* AND is_audio_of_ssim:\"info\:fedora/#{pid.gsub(':', '\:')}\" AND has_model_ssim:\"info\:fedora/afmodel:Bplmodels_AudioFile\""})
      solr_response.documents&.first
    end

    def get_first_document_file(pid)
      solr_response = repository.search({q: "-is_following_document_of_ssim:* AND is_document_of_ssim:\"info\:fedora/#{pid.gsub(':', '\:')}\" AND has_model_ssim:\"info\:fedora/afmodel:Bplmodels_DocumentFile\""})
      solr_response.documents&.first
    end

    def get_first_ereader_file(pid)
      solr_response = repository.search({q: "-is_following_ereader_of_ssim:* AND is_document_of_ssim:\"info\:fedora/#{pid.gsub(':', '\:')}\" AND has_model_ssim:\"info\:fedora/afmodel:Bplmodels_EreaderFile\""})
      solr_response.documents&.first
    end

    def get_next_volume_object(pid)
      solr_response = repository.search({q: "is_following_volume_of_ssim:\"info\:fedora/#{pid.gsub(':', '\:')}\" AND has_model_ssim:\"info\:fedora/afmodel:Bplmodels_Volume\""})
      solr_response.documents&.first
    end

    def get_next_image_file(pid)
      solr_response = repository.search({q: "is_following_image_of_ssim:\"info\:fedora/#{pid.gsub(':', '\:')}\" AND has_model_ssim:\"info\:fedora/afmodel:Bplmodels_ImageFile\""})
      solr_response.documents&.first
    end

    def get_next_audio_file(pid)
      solr_response = repository.search({q: "is_following_audio_of_ssim:\"info\:fedora/#{pid.gsub(':', '\:')}\" AND has_model_ssim:\"info\:fedora/afmodel:Bplmodels_AudioFile\""})
      solr_response.documents&.first
    end

    def get_next_document_file(pid)
      solr_response = repository.search({q: "is_following_document_of_ssim:\"info\:fedora/#{pid.gsub(':', '\:')}\" AND has_model_ssim:\"info\:fedora/afmodel:Bplmodels_DocumentFile\""})
      solr_response.documents&.first
    end

    def get_next_ereader_file(pid)
      solr_response = repository.search({q: "is_following_ereader_of_ssim:\"info\:fedora/#{pid.gsub(':', '\:')}\" AND has_model_ssim:\"info\:fedora/afmodel:Bplmodels_EreaderFile\""})
      solr_response.documents&.first
    end

    def get_prev_volume_object(pid)
      solr_response = repository.search({q: "is_preceding_volume_of_ssim:\"info\:fedora/#{pid.gsub(':', '\:')}\" AND has_model_ssim:\"info\:fedora/afmodel:Bplmodels_Volume\""})
      solr_response.documents&.first
    end

    def get_prev_image_file(pid)
      solr_response = repository.search({q: "is_preceding_image_of_ssim:\"info\:fedora/#{pid.gsub(':', '\:')}\" AND has_model_ssim:\"info\:fedora/afmodel:Bplmodels_ImageFile\""})
      solr_response.documents&.first
    end

    def get_prev_audio_file(pid)
      solr_response = repository.search({q: "is_preceding_audio_of_ssim:\"info\:fedora/#{pid.gsub(':', '\:')}\" AND has_model_ssim:\"info\:fedora/afmodel:Bplmodels_AudioFile\""})
      solr_response.documents&.first
    end

    def get_prev_document_file(pid)
      solr_response = repository.search({q: "is_preceding_document_of_ssim:\"info\:fedora/#{pid.gsub(':', '\:')}\" AND has_model_ssim:\"info\:fedora/afmodel:Bplmodels_DocumentFile\""})
      solr_response.documents&.first
    end

    def get_prev_ereader_file(pid)
      solr_response = repository.search({q: "is_preceding_ereader_of_ssim:\"info\:fedora/#{pid.gsub(':', '\:')}\" AND has_model_ssim:\"info\:fedora/afmodel:Bplmodels_EreaderFile\""})
      solr_response.documents&.first
    end

    def get_volume_parent_object(volume_pid)
      solr_response = repository.search({q: "id:\"#{volume_pid}\" AND has_model_ssim:\"info:fedora/afmodel:Bplmodels_Volume\""})
      solr_response.documents&.first
    end

    def get_file_parent_object(file_pid)
      solr_response = repository.search({q: "id:\"#{file_pid}\" AND has_model_ssim:\"info:fedora/afmodel:Bplmodels_File\""})
      return nil if solr_response.documents.blank?

      doc = solr_response.documents.first
      parent_field_values = doc['is_file_of_ssim']
      return nil if parent_field_values.blank?

      SolrDocument.find(parent_field_values.first.gsub(/info:fedora\//, ''))
    end
  end
end
