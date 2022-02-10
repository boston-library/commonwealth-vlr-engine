# frozen_string_literal: true

module CommonwealthVlrEngine
  module Finder
    def repository
      Blacklight.default_index
    end

    def get_files(pid)
      return_hash = {}
      file_types = %i(image document audio ereader video)
      file_types.each { |file_type| return_hash[file_type] = [] }

      solr_response = repository.search({ q: "is_file_set_of_ssim:\"#{pid}\"", rows: 5000 })

      solr_response.documents.each do |solr_doc|
        # found_model = false
        file_types.each do |file_type|
          if solr_doc['curator_model_suffix_ssi'] == file_type.to_s.capitalize
            return_hash[file_type] << solr_doc
            # found_model = true
          end
        end
        # return_hash[:generic] << solr_doc unless found_model
      end

      file_types.each do |file_type|
        return_hash[file_type] = return_hash[file_type].sort_by { |f| f['position_isi'] }
      end

      return_hash
    end

    def get_image_files(pid)
      get_files(pid)[:image]
    end
  end
end
