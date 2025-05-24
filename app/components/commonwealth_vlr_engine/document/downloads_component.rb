# frozen_string_literal: true

module CommonwealthVlrEngine
  module Document
    class DownloadsComponent < ViewComponent::Base
      def initialize(document:, object_files:)
        @document = document
        @object_files = object_files
      end
      attr_reader :document, :object_files

      # create an array of download links
      # images/video have to be handled separately since there are multiple sizes
      def download_links
        download_links = []
        download_links.concat(image_download_links(object_files[:image])) if helpers.has_downloadable_images?(document, object_files)
        download_links.concat(video_download_links(object_files[:video])) if helpers.has_downloadable_video?(document, object_files)
        download_links.concat(other_download_links)
        download_links
      end

      def download_link_class
        'sidebar_downloads_link'
      end

      def download_link_options
        { class: download_link_class, rel: 'nofollow', data: { blacklight_modal: 'trigger' } }
      end

      def download_link_title(attachments, filestream_id = nil)
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

      def image_filestreams(attachments_json)
        image_filestreams = []
        stored_filestreams = %w(image_primary image_access_800 image_georectified_primary)
        stored_filestreams.each do |filestream_id|
          image_filestreams << filestream_id if attachments_json[filestream_id].present?
        end
        image_filestreams.insert(1, 'image_access_full')
      end

      def image_download_links(image_files)
        if document[:identifier_ia_id_ssi]
          [file_download_link(document[:id],
                              t('blacklight.downloads.images.image_access_full'),
                              nil,
                              'JPEG2000',
                              download_link_options)]
        else
          attachments_json = JSON.parse(image_files.first['attachments_ss'])
          image_links = []
          image_filestreams(attachments_json).each do |filestream_id|
            if image_files.length == 1
              attachments = attachments_json
              object_id = image_files.first['id']
            else
              attachments = setup_zip_attachments(image_files, filestream_id)
              object_id = document[:id]
            end
            image_links << file_download_link(object_id,
                                              t("blacklight.downloads.images.#{filestream_id}"),
                                              attachments,
                                              filestream_id,
                                              download_link_options)
          end
          image_links
        end
      end

      # for now, we only support video_access_mp4 download
      def video_download_links(video_files)
        file = video_files.first
        video_links = []
        attachments_json = JSON.parse(file['attachments_ss'])
        %w(video_access_mp4 video_access_webm).each do |v_id|
          next unless attachments_json[v_id]

          video_links << file_download_link(file['id'],
                                            download_link_title(attachments_json, v_id),
                                            attachments_json,
                                            v_id,
                                            download_link_options)
        end
        video_links
      end

      # everything except image and video
      def other_download_links
        other_links = []
        other_file_types = [object_files[:audio], object_files[:document], object_files[:ereader]]
        other_file_types.each do |file_type|
          file_type.each do |file|
            attachments_json = JSON.parse(file['attachments_ss'])
            other_downloadable_attachments(attachments_json).each do |att_type|
              next if attachments_json[att_type].blank?

              other_links << file_download_link(file['id'],
                                                download_link_title(attachments_json, att_type),
                                                attachments_json,
                                                att_type,
                                                download_link_options)
            end
          end
        end
        other_links
      end

      # @return [Array] list non-image/video downloadable attachments
      def other_downloadable_attachments(attachments_json)
        downloadable_attachments = %w(audio_access document_access ebook_access_epub ebook_access_mobi
                                    ebook_access_daisy text_plain)
        all_attachments = attachments_json.keys

        # don't allow download of *_primary or text_plain if there is an *_access file
        downloadable_attachments << 'audio_primary' unless all_attachments.include?('audio_access')
        downloadable_attachments << 'document_primary' unless all_attachments.include?('document_access')
        downloadable_attachments.delete('text_plain') if all_attachments.include?('document_access')

        downloadable_attachments
      end

      def file_download_link(object_pid, link_title, attachments_json, filestream_id, link_options = {})
        link_to(link_title,
                helpers.download_path(object_pid, filestream_id: filestream_id),
                link_options) + content_tag(:span,
                                            "(#{file_type_string(filestream_id, attachments_json)}, #{file_size_string(filestream_id, attachments_json)})",
                                            class: 'download_info')
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

      # create a composite attachments_json object from multiple file objects
      # used to display size of ZIP archive
      def setup_zip_attachments(image_files, filestream_id)
        filestream_id_to_use = filestream_id == 'image_access_full' ? 'image_service' : filestream_id
        attachments = { zip: true,
                        filename: filestream_id == 'image_primary' ? '.TIF' : '.JPEG',
                        filestream_id_to_use.to_sym => {} }
        zip_size = 0
        image_files.each do |image_file|
          img_attachments_json = JSON.parse(image_file['attachments_ss'])
          zip_size += img_attachments_json[filestream_id_to_use]['byte_size']
        end
        # estimate compression, pretty rough
        zip_size = case filestream_id
                   when 'image_primary'
                     zip_size * 0.798
                   when 'image_access_full'
                     zip_size * 0.839
                   else
                     zip_size * 0.927
                   end
        attachments[filestream_id_to_use.to_sym][:byte_size] = zip_size
        attachments.deep_stringify_keys
      end

      def url_for_download(filestream_id)
        if document[:identifier_ia_id_ssi] && filestream_id == 'JPEG2000'
          "https://archive.org/download/#{document[:identifier_ia_id_ssi]}/#{document[:identifier_ia_id_ssi]}_jp2.zip"
        elsif document[blacklight_config.index.display_type_field] == 'DigitalObject'
          helpers.trigger_zip_downloads_path(document.id, filestream_id: filestream_id)
        else
          helpers.trigger_downloads_path(document.id, filestream_id: filestream_id)
        end
      end
    end
  end
end
