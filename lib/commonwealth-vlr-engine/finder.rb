module CommonwealthVlrEngine
  module Finder
    #include Blacklight::SearchHelper

    def get_files(pid)

      return_hash = {}
      return_hash[:images] = []
      return_hash[:documents] = []
      return_hash[:audio] = []
      return_hash[:ereader] = []
      return_hash[:generic] = []

      solr_response = repository.search({:q => "is_file_of_ssim:\"info:fedora/#{pid}\"", :rows => 1000})

      solr_response.documents.each do |solr_doc|
        if solr_doc['has_model_ssim'].include?('info:fedora/afmodel:Bplmodels_AudioFile')
          return_hash[:audio] << solr_doc
        elsif solr_doc['has_model_ssim'].include?('info:fedora/afmodel:Bplmodels_ImageFile')
          return_hash[:images] << solr_doc
        elsif solr_doc['has_model_ssim'].include?('info:fedora/afmodel:Bplmodels_DocumentFile')
          return_hash[:documents] << solr_doc
        elsif solr_doc['has_model_ssim'].include?('info:fedora/afmodel:Bplmodels_EreaderFile')
          return_hash[:ereader] << solr_doc
        else
          return_hash[:generic] << solr_doc
        end
      end

       return_hash[:images] = sort_files(return_hash[:images])
       return_hash[:documents] = sort_files(return_hash[:documents])
       return_hash[:audio] = sort_files(return_hash[:audio])
       return_hash[:ereader] = sort_files(return_hash[:ereader])
       return_hash[:generic] = sort_files(return_hash[:generic])

       return return_hash
    end


    def sort_files(file_list)
      return file_list if file_list.length <= 1

      following_key_final = nil
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
          following_key_final = following_key.first
          return_list.insert(-1, file)
          ending_item_pid  = "info:fedora/#{file['id']}"
        end
      end

      while next_item_pid != ending_item_pid
        next_item = file_list.select { |array| "info:fedora/#{array['id'].to_s}" == next_item_pid }.first
        return_list.insert(-2, next_item)
        next_item_pid = next_item[preceding_key_final].first.to_s
      end

      return return_list
    end

    def get_volume_objects(pid)
      return_list = []
      volumes_list = []
      solr_response = repository.search({:q => "is_volume_of_ssim:\"info\:fedora/#{pid.gsub(':', '\:')}\" AND has_model_ssim:\"info\:fedora/afmodel:Bplmodels_Volume\"", :rows => 1000})

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
      return_list = []
      solr_response = repository.search({:q => "is_image_of_ssim:\"info\:fedora/#{pid.gsub(':', '\:')}\" AND has_model_ssim:\"info\:fedora/afmodel:Bplmodels_ImageFile\"", :rows => 1000})

      solr_response.documents.each do |solr_object|
        return_list << solr_object
      end
      return sort_files(return_list)
    end

    def get_audio_files(pid)
      return_list = []
      solr_response = repository.search({:q => "is_audio_of_ssim:\"info\:fedora/#{pid.gsub(':', '\:')} AND has_model_ssim:\"info\:fedora/afmodel:Bplmodels_AudioFile\"", :rows => 1000})

      solr_response.documents.each do |solr_object|
        return_list << solr_object
      end
      return sort_files(return_list)
    end

    def get_document_files(pid)
      return_list = []
      solr_response = repository.search({:q => "is_document_of_ssim:\"info\:fedora/#{pid.gsub(':', '\:')}\" AND has_model_ssim:\"info\:fedora/afmodel:Bplmodels_DocumentFile\"", :rows => 1000})

      solr_response.documents.each do |solr_object|
        return_list << solr_object
      end
      return sort_files(return_list)
    end

    def get_ereader_files(pid)
      return_list = []
      solr_response = repository.search({:q => "is_ereader_of_ssim:\"info\:fedora/#{pid.gsub(':', '\:')}\" AND has_model_ssim:\"info\:fedora/afmodel:Bplmodels_EreaderFile\"", :rows => 1000})

      solr_response.documents.each do |solr_object|
        return_list << solr_object
      end
      return sort_files(return_list)
    end

    def get_first_volume_object(pid)
      return_list = []
      solr_response = repository.search({:q => "-is_following_volume_of_ssim:* AND is_volume_of_ssim:\"info\:fedora/#{pid.gsub(':', '\:')}\" AND has_model_ssim:\"info\:fedora/afmodel:Bplmodels_Volume\""})

      solr_response.documents.each do |solr_object|
        return_list << solr_object
      end
      return sort_files(return_list)
    end

    def get_first_image_file(pid)
      solr_response = repository.search({:q => "-is_following_image_of_ssim:* AND is_image_of_ssim:\"info\:fedora/#{pid.gsub(':', '\:')}\" AND has_model_ssim:\"info\:fedora/afmodel:Bplmodels_ImageFile\""})

      solr_response.documents.each do |solr_object|
        return solr_object
      end
      return nil
    end

    def get_first_audio_file(pid)
      solr_response = repository.search({:q => "-is_following_audio_of_ssim:* AND is_audio_of_ssim:\"info\:fedora/#{pid.gsub(':', '\:')}\" AND has_model_ssim:\"info\:fedora/afmodel:Bplmodels_AudioFile\""})

      solr_response.documents.each do |solr_object|
        return solr_object
      end
      return nil
    end

    def get_first_document_file(pid)
      solr_response = repository.search({:q => "-is_following_document_of_ssim:* AND is_document_of_ssim:\"info\:fedora/#{pid.gsub(':', '\:')}\" AND has_model_ssim:\"info\:fedora/afmodel:Bplmodels_DocumentFile\""})

      solr_response.documents.each do |solr_object|
        return solr_object
      end
      return nil
    end

    def get_first_ereader_file(pid)
      solr_response = repository.search({:q => "-is_following_ereader_of_ssim:* AND is_document_of_ssim:\"info\:fedora/#{pid.gsub(':', '\:')}\" AND has_model_ssim:\"info\:fedora/afmodel:Bplmodels_EreaderFile\""})

      solr_response.documents.each do |solr_object|
        return solr_object
      end
      return nil
    end

    def get_next_volume_object(pid)
      solr_response = repository.search({:q => "is_following_volume_of_ssim:\"info\:fedora/#{pid.gsub(':', '\:')}\" AND has_model_ssim:\"info\:fedora/afmodel:Bplmodels_Volume\""})

      solr_response.documents.each do |solr_object|
        return solr_object
      end
      return nil
    end

    def get_next_image_file(pid)
      solr_response = repository.search({:q => "is_following_image_of_ssim:\"info\:fedora/#{pid.gsub(':', '\:')}\" AND has_model_ssim:\"info\:fedora/afmodel:Bplmodels_ImageFile\""})

      solr_response.documents.each do |solr_object|
        return solr_object
      end
      return nil
    end

    def get_next_audio_file(pid)
      solr_response = repository.search({:q => "is_following_audio_of_ssim:\"info\:fedora/#{pid.gsub(':', '\:')}\" AND has_model_ssim:\"info\:fedora/afmodel:Bplmodels_AudioFile\""})

      solr_response.documents.each do |solr_object|
        return solr_object
      end
      return nil
    end

    def get_next_document_file(pid)
      solr_response = repository.search({:q => "is_following_document_of_ssim:\"info\:fedora/#{pid.gsub(':', '\:')}\" AND has_model_ssim:\"info\:fedora/afmodel:Bplmodels_DocumentFile\""})

      solr_response.documents.each do |solr_object|
        return solr_object
      end
      return nil
    end

    def get_next_ereader_file(pid)
      solr_response = repository.search({:q => "is_following_ereader_of_ssim:\"info\:fedora/#{pid.gsub(':', '\:')}\" AND has_model_ssim:\"info\:fedora/afmodel:Bplmodels_EreaderFile\""})

      solr_response.documents.each do |solr_object|
        return solr_object
      end
      return nil
    end

    def get_prev_volume_object(pid)
      solr_response = repository.search({:q => "is_preceding_volume_of_ssim:\"info\:fedora/#{pid.gsub(':', '\:')}\" AND has_model_ssim:\"info\:fedora/afmodel:Bplmodels_Volume\""})

      solr_response.documents.each do |solr_object|
        return solr_object
      end
      return nil
    end

    def get_prev_image_file(pid)
      solr_response = repository.search({:q => "is_preceding_image_of_ssim:\"info\:fedora/#{pid.gsub(':', '\:')}\" AND has_model_ssim:\"info\:fedora/afmodel:Bplmodels_ImageFile\""})

      solr_response.documents.each do |solr_object|
        return solr_object
      end
      return nil
    end

    def get_prev_audio_file(pid)
      solr_response = repository.search({:q => "is_preceding_audio_of_ssim:\"info\:fedora/#{pid.gsub(':', '\:')}\" AND has_model_ssim:\"info\:fedora/afmodel:Bplmodels_AudioFile\""})

      solr_response.documents.each do |solr_object|
        return solr_object
      end
      return nil
    end

    def get_prev_document_file(pid)
      solr_response = repository.search({:q => "is_preceding_document_of_ssim:\"info\:fedora/#{pid.gsub(':', '\:')}\" AND has_model_ssim:\"info\:fedora/afmodel:Bplmodels_DocumentFile\""})

      solr_response.documents.each do |solr_object|
        return solr_object
      end
      return nil
    end

    def get_prev_ereader_file(pid)
      solr_response = repository.search({:q => "is_preceding_ereader_of_ssim:\"info\:fedora/#{pid.gsub(':', '\:')}\" AND has_model_ssim:\"info\:fedora/afmodel:Bplmodels_EreaderFile\""})

      solr_response.documents.each do |solr_object|
        return solr_object
      end
      return nil
    end

    def get_volume_parent_object(volume_pid)
      solr_response = repository.search({:q => "id:\"#{volume_pid}\" AND has_model_ssim:\"info:fedora/afmodel:Bplmodels_Volume\""})

      solr_response.documents.each do |solr_object|
        return solr_object['is_volume_of_ssim'].first.split('/')[1]
      end

      return nil
    end

    def get_file_parent_object(file_pid)
      solr_response = repository.search({:q => "id:\"#{file_pid}\" AND has_model_ssim:\"info:fedora/afmodel:Bplmodels_File\""})

      solr_response.documents.each do |solr_object|
        return solr_object['is_file_of_ssim'].first.split('/')[1]
      end

      return nil
    end

  end
end