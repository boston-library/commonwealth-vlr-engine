# frozen_string_literal: true

module CommonwealthVlrEngine
  module ApplicationHelper
    # show the display-friendly value for the Format facet
    def render_format(value)
      case value
      when 'Albums (Books)'
        'Albums/Scrapbooks'
      when 'Drawings'
        'Drawings/Illustrations'
      when 'Maps'
        'Maps/Atlases'
      when 'Motion pictures'
        'Film/Video'
      when 'Music'
        'Music (recordings)'
      when 'Objects'
        'Objects/Artifacts'
      when 'Musical notation'
        'Sheet music'
      when 'Sound recordings'
        'Audio recordings (nonmusical)'
      when 'Cards'
        'Postcards/Cards'
      when 'Correspondence'
        'Letters/Correspondence'
      else
        value
      end
    end

    def render_format_index(options = {})
      options[:value].map { |v| render_format(v) }.join('; ')
    end

    # return the path to the icon for objects with no thumbnail
    def render_object_icon_path(format)
      icon = case format
             when 'still image'
               'image'
             when 'sound recording', 'sound recording-nonmusical', 'sound recording-musical'
               'audio'
             when 'moving image'
               'moving-image'
             else
               'text'
             end
      "commonwealth-vlr-engine/dc_#{icon}-icon.png"
    end

    def link_to_facet(field_value, field, displayvalue = nil)
      if field == 'genre_basic_ssim'
        link_to(render_format(field_value), search_catalog_path(f: { field => [field_value] }))
      else
        link_to(displayvalue.presence || field_value, search_catalog_path(f: { field => [field_value] }))
      end
    end

    # link to a combination of facets (series + subseries, for ex)
    def link_to_facets(field_values, fields, displayvalue = nil)
      facets = {}
      fields.each_with_index do |field, index|
        facets[field] = [field_values[index]]
      end
      link_to(displayvalue.presence || field_values[0], search_catalog_path(f: facets))
    end

    def link_to_county_facet(field_value, field)
      link_to(field_value + ' County', search_catalog_path(f: { field => [field_value + ' (county)'] }))
    end

    # returns the direct URL to a filestream blob in storage
    # @param key [String] storage key base, e.g. "images/commonwealth:123456789"
    # @param attachment_id [String] attachment type
    # @param full_key [Boolean] true if we are passing the full key (with extension) as key param
    def filestream_disseminator_url(key, attachment_id, full_key = false)
      return primary_filestream_url(key, attachment_id, full_key) if attachment_id.match?(/primary/)

      return "#{ASSET_STORE['url']}/derivatives/#{key}" if full_key

      file_ext = case attachment_id
                 when 'image_thumbnail_300', 'image_access_800'
                   'jpg'
                 when 'image_service'
                   'jp2'
                 when 'text_coordinates_access'
                   'json'
                 when 'video_access_mp4'
                   'mp4'
                 when 'video_access_webm'
                   'webm'
                 when 'audio_access'
                   'mp3'
                 when 'document_access'
                   'pdf'
                 when 'ebook_access_epub'
                   'epub'
                 when 'ebook_access_mobi'
                   'mobi'
                 when 'ebook_access_daisy'
                   'zip'
                 when 'text_plain'
                   'txt'
                 end
      "#{ASSET_STORE['url']}/derivatives/#{key}/#{attachment_id}.#{file_ext}"
    end

    # returns the signed URL to a filestream blob in 'primary' container (private)
    # @param key [String] storage key base, e.g. "images/commonwealth:123456789"
    # @param attachment_id [String] attachment type
    # @param full_key [Boolean] true if we are passing the full key (with extension) as key param
    def primary_filestream_url(key, attachment_id, full_key = false)
      key = key.gsub(/\/[\w\.]*\z/, '') if full_key
      api_url = "#{CURATOR['url']}/filestreams/#{key}?show_primary_url=true"
      curator_response = Typhoeus::Request.get(api_url)
      if curator_response.response_code == 200 && curator_response.body.present?
        filestream_data = JSON.parse(curator_response.body)
        filestream_data.fetch('file_set')&.fetch("#{attachment_id}_url", '')
      else
        ''
      end
    end

    # create an image tag from an IIIF image server
    def iiif_image_tag(image_pid, options)
      image_tag(iiif_image_url(image_pid, options),
                alt: options[:alt].presence,
                class: options[:class].presence)
    end

    # return the IIIF image url
    def iiif_image_url(image_pid, options)
      size = options[:size] ? options[:size] : 'full'
      region = options[:region] ? options[:region] : 'full'
      "#{IIIF_SERVER['url']}#{image_pid}/#{region}/#{size}/0/default.jpg"
    end

    # returns a hash with width/height from IIIF info.json response
    def get_image_metadata(image_pid)
      iiif_response = Typhoeus::Request.get(IIIF_SERVER['url'] + image_pid + '/info.json')
      if iiif_response.response_code == 200 && !iiif_response.response_body.empty?
        iiif_info = JSON.parse(iiif_response.body)
        height = iiif_info['height'].to_i
        width = iiif_info['width'].to_i
        aspect_ratio = (width.to_f / height.to_f).to_f
        img_metadata = { height: height, width: width, aspect_ratio: aspect_ratio }
      else
        img_metadata = { height: 0, width: 0, aspect_ratio: 0 }
      end
      img_metadata
    end

    def insert_google_analytics
      return unless Rails.env.to_s == 'production'

      content_for(:head) do
        render partial: '/layouts/google_analytics'
      end
    end

    # returns a hash with the location of the OpenSeadragon custom images
    def osd_nav_images(path_to_directory)
      {
        zoomIn: {
          REST:   path_to_image("#{path_to_directory}/zoomin_rest.png"),
          GROUP:  path_to_image("#{path_to_directory}/zoomin_grouphover.png"),
          HOVER:  path_to_image("#{path_to_directory}/zoomin_hover.png"),
          DOWN:   path_to_image("#{path_to_directory}/zoomin_pressed.png")
        },
        zoomOut: {
          REST:   path_to_image("#{path_to_directory}/zoomout_rest.png"),
          GROUP:  path_to_image("#{path_to_directory}/zoomout_grouphover.png"),
          HOVER:  path_to_image("#{path_to_directory}/zoomout_hover.png"),
          DOWN:   path_to_image("#{path_to_directory}/zoomout_pressed.png")
        },
        home: {
          REST:   path_to_image("#{path_to_directory}/home_rest.png"),
          GROUP:  path_to_image("#{path_to_directory}/home_grouphover.png"),
          HOVER:  path_to_image("#{path_to_directory}/home_hover.png"),
          DOWN:   path_to_image("#{path_to_directory}/home_pressed.png")
        },
        fullpage: {
          REST:   path_to_image("#{path_to_directory}/fullpage_rest.png"),
          GROUP:  path_to_image("#{path_to_directory}/fullpage_grouphover.png"),
          HOVER:  path_to_image("#{path_to_directory}/fullpage_hover.png"),
          DOWN:   path_to_image("#{path_to_directory}/fullpage_pressed.png")
        },
        rotateleft: {
          REST:   path_to_image("#{path_to_directory}/rotateleft_rest.png"),
          GROUP:  path_to_image("#{path_to_directory}/rotateleft_grouphover.png"),
          HOVER:  path_to_image("#{path_to_directory}/rotateleft_hover.png"),
          DOWN:   path_to_image("#{path_to_directory}/rotateleft_pressed.png")
        },
        rotateright: {
          REST:   path_to_image("#{path_to_directory}/rotateright_rest.png"),
          GROUP:  path_to_image("#{path_to_directory}/rotateright_grouphover.png"),
          HOVER:  path_to_image("#{path_to_directory}/rotateright_hover.png"),
          DOWN:   path_to_image("#{path_to_directory}/rotateright_pressed.png")
        },
        previous: {
          REST:   path_to_image("#{path_to_directory}/previous_rest.png"),
          GROUP:  path_to_image("#{path_to_directory}/previous_grouphover.png"),
          HOVER:  path_to_image("#{path_to_directory}/previous_hover.png"),
          DOWN:   path_to_image("#{path_to_directory}/previous_pressed.png")
        },
        next: {
          REST:   path_to_image("#{path_to_directory}/next_rest.png"),
          GROUP:  path_to_image("#{path_to_directory}/next_grouphover.png"),
          HOVER:  path_to_image("#{path_to_directory}/next_hover.png"),
          DOWN:   path_to_image("#{path_to_directory}/next_pressed.png")
        }
      }.to_json
    end

    # adds apple-touch-icon tags to <head>
    def render_mobile_icon_tags
      render partial: 'shared/mobile_icon_tags'
    end
  end
end
