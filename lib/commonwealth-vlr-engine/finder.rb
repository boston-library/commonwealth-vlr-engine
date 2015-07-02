module CommonwealthVlrEngine
  class Finder
    include Blacklight::SearchHelper

    #def self.getFiles(pid)
    def self.getFiles(pid)
      return_hash = {}
      return_hash[:images] = []
      return_hash[:documents] = []
      return_hash[:audio] = []
      return_hash[:generic] = []

      @solr_response =  Blacklight.solr.get 'select', :params => {:q => "is_file_of_ssim:\"info:fedora/#{pid}\""}

      @solr_response["response"]["docs"].each do |solr_object|
        if solr_object['has_model_ssim'].include?('info:fedora/afmodel:Bplmodels_AudioFile')
          return_hash[:audio] << solr_object
        elsif solr_object['has_model_ssim'].include?('info:fedora/afmodel:Bplmodels_ImageFile')
          return_hash[:images] << solr_object
        elsif solr_object['has_model_ssim'].include?('info:fedora/afmodel:Bplmodels_DocumentFile')
          return_hash[:documents] << solr_object
        else
          return_hash[:generic] << solr_object
        end
      end

       return_hash[:images] = sort_files(return_hash[:images])
       return_hash[:documents] = sort_files(return_hash[:documents])
       return_hash[:audio] = sort_files(return_hash[:audio])
       return_hash[:generic] = sort_files(return_hash[:generic])

       return return_hash
    end


    def self.sort_files(file_list)
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

    def self.getImageFiles(pid)
      return_list = []
      @solr_response =  Blacklight.solr.get 'select', :params => {:q => "is_image_of_ssim:\"info\:fedora/#{pid.gsub(':', '\:')}\" AND has_model_ssim:\"info\:fedora/afmodel:Bplmodels_ImageFile\""}

      @solr_response["response"]["docs"].each do |solr_object|
        return_list << solr_object
      end
      return sort_files(return_list)
    end

    def self.getAudioFiles(pid)
      return_list = []
      @solr_response =  Blacklight.solr.get 'select', :params => {:q => "is_audio_of_ssim:\"info\:fedora/#{pid.gsub(':', '\:')} AND has_model_ssim:\"info\:fedora/afmodel:Bplmodels_AudioFile\""}

      @solr_response["response"]["docs"].each do |solr_object|
        return_list << solr_object
      end
      return sort_files(return_list)
    end

    def self.getDocumentFiles(pid)
      return_list = []
      @solr_response =  Blacklight.solr.get 'select', :params => {:q => "is_document_of_ssim:\"info\:fedora/#{pid.gsub(':', '\:')}\" AND has_model_ssim:\"info\:fedora/afmodel:Bplmodels_DocumentFile\""}

      @solr_response["response"]["docs"].each do |solr_object|
        return_list << solr_object
      end
      return sort_files(return_list)
    end

    def self.getFirstImageFile(pid)
      @solr_response =  Blacklight.solr.get 'select', :params => {:q => "-is_following_image_of_ssim:* AND is_image_of_ssim:\"info\:fedora/#{pid.gsub(':', '\:')}\" AND has_model_ssim:\"info\:fedora/afmodel:Bplmodels_ImageFile\""}

      @solr_response["response"]["docs"].each do |solr_object|
        return solr_object
      end
      return nil
    end

    def self.getFirstAudioFile(pid)
      @solr_response =  Blacklight.solr.get 'select', :params => {:q => "-is_following_audio_of_ssim:* AND is_audio_of_ssim:\"info\:fedora/#{pid.gsub(':', '\:')}\" AND has_model_ssim:\"info\:fedora/afmodel:Bplmodels_AudioFile\""}

      @solr_response["response"]["docs"].each do |solr_object|
        return solr_object
      end
      return nil
    end

    def self.getFirstDocumentFile(pid)
      @solr_response =  Blacklight.solr.get 'select', :params => {:q => "-is_following_document_of_ssim:* AND is_document_of_ssim:\"info\:fedora/#{pid.gsub(':', '\:')}\" AND has_model_ssim:\"info\:fedora/afmodel:Bplmodels_DocumentFile\""}

      @solr_response["response"]["docs"].each do |solr_object|
        return solr_object
      end
      return nil
    end

    def self.getNextImageFile(pid)
      @solr_response =  Blacklight.solr.get 'select', :params => {:q => "is_following_image_of_ssim:\"info\:fedora/#{pid.gsub(':', '\:')}\" AND has_model_ssim:\"info\:fedora/afmodel:Bplmodels_ImageFile\""}

      @solr_response["response"]["docs"].each do |solr_object|
        return solr_object
      end
      return nil
    end

    def self.getNextAudioFile(pid)
      @solr_response =  Blacklight.solr.get 'select', :params => {:q => "is_following_audio_of_ssim:\"info\:fedora/#{pid.gsub(':', '\:')}\" AND has_model_ssim:\"info\:fedora/afmodel:Bplmodels_AudioFile\""}

      @solr_response["response"]["docs"].each do |solr_object|
        return solr_object
      end
      return nil
    end

    def self.getNextDocumentFile(pid)
      @solr_response =  Blacklight.solr.get 'select', :params => {:q => "is_following_document_of_ssim:\"info\:fedora/#{pid.gsub(':', '\:')}\" AND has_model_ssim:\"info\:fedora/afmodel:Bplmodels_DocumentFile\""}

      @solr_response["response"]["docs"].each do |solr_object|
        return solr_object
      end
      return nil
    end

    def self.getPrevImageFile(pid)
      @solr_response =  Blacklight.solr.get 'select', :params => {:q => "is_preceding_image_of_ssim:\"info\:fedora/#{pid.gsub(':', '\:')}\" AND has_model_ssim:\"info\:fedora/afmodel:Bplmodels_ImageFile\""}

      @solr_response["response"]["docs"].each do |solr_object|
        return solr_object
      end
      return nil
    end

    def self.getPrevAudioFile(pid)
      @solr_response =  Blacklight.solr.get 'select', :params => {:q => "is_preceding_audio_of_ssim:\"info\:fedora/#{pid.gsub(':', '\:')}\" AND has_model_ssim:\"info\:fedora/afmodel:Bplmodels_AudioFile\""}

      @solr_response["response"]["docs"].each do |solr_object|
        return solr_object
      end
      return nil
    end

    def self.getPrevDocumentFile(pid)
      @solr_response =  Blacklight.solr.get 'select', :params => {:q => "is_preceding_document_of_ssim:\"info\:fedora/#{pid.gsub(':', '\:')}\" AND has_model_ssim:\"info\:fedora/afmodel:Bplmodels_DocumentFile\""}

      @solr_response["response"]["docs"].each do |solr_object|
        return solr_object
      end
      return nil
    end

    def self.getFileParentObject(file_pid)
      @solr_response =  Blacklight.solr.get 'select', :params => {:q => "id:\"info\:fedora/#{file_pid.gsub(':', '\:')}\" AND has_model_ssim:\"info\:fedora/afmodel:Bplmodels_File\""}

      @solr_response["response"]["docs"].each do |solr_object|
        return solr_object['is_file_of_ssim'].first.split('/')[1]
      end

      return nil
    end

  end
end