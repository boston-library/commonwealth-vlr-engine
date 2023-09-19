# frozen_string_literal: true

module CommonwealthVlrEngine
  module Finder
    def get_files(pid)
      return_hash = {}
      file_types = %i(image document audio ereader video)
      file_types.each { |file_type| return_hash[file_type] = [] }

      solr_response = Blacklight.default_index.search({ q: "is_file_set_of_ssim:\"#{pid}\"", rows: 5000 })

      solr_response.documents.each do |solr_doc|
        file_types.each do |file_type|
          if solr_doc['curator_model_suffix_ssi'] == file_type.to_s.capitalize
            return_hash[file_type] << solr_doc
          end
        end
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
