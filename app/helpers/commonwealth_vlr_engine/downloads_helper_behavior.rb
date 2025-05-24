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
  end
end
