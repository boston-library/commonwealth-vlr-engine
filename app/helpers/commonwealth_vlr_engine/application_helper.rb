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

    def render_format_index(options={})
      options[:value].map { |v| render_format(v) }.join('; ')
    end

    # return the path to the icon for objects with no thumbnail
    def render_object_icon_path(format)
      case format
        when 'still image'
          icon = 'image'
        when 'sound recording', 'sound recording-nonmusical', 'sound recording-musical'
          icon = 'audio'
        when 'moving image'
          icon = 'moving-image'
        else
          icon = 'text'
      end
      "commonwealth-vlr-engine/dc_#{icon}-icon.png"
    end

    # render date range constraints from Advanced Search form
    # used by CommonwealthVlrEngine::RenderConstraintsOverride
    # and CommonwealthVlrEngine::SearchHistoryConstraintsHelper
    def date_range_constraints_to_s(params)
      if params[:date_start].blank?
        "before #{params[:date_end]}"
      elsif params[:date_end].blank?
        "after #{params[:date_start]}"
      else
        "#{params[:date_start]}-#{params[:date_end]}"
      end
    end

    #from psu scholarsphere
    # TODO: this isn't used anywhere in the app, get rid of it?
    def link_to_field(fieldname, fieldvalue, displayvalue = nil)
      p = {:search_field => fieldname, :q => '"'+fieldvalue+'"'}
      link_url = search_catalog_path(p)
      display = displayvalue.blank? ? fieldvalue: displayvalue
      link_to(display, link_url)
    end

    def link_to_facet(field_value, field, displayvalue = nil)
      if field == 'genre_basic_ssim'
        link_to(render_format(field_value), search_catalog_path(:f => {field => [field_value]}))
      else
        link_to(displayvalue.presence || field_value, search_catalog_path(:f => {field => [field_value]}))
      end
    end

    # link to a combination of facets (series + subseries, for ex)
    def link_to_facets(field_values, fields, displayvalue = nil)
      facets = {}
      fields.each_with_index do |field, index|
        facets[field] = [field_values[index]]
      end
      link_to(displayvalue.presence || field_values[0], search_catalog_path(:f => facets))
    end

    def link_to_county_facet(field_value, field)
      link_to(field_value + ' County', search_catalog_path(:f => {field => [field_value + ' (county)']}))
    end

    # returns the direct URL to a datastream in Fedora
    def datastream_disseminator_url pid, datastream_id
      "#{FEDORA_URL['url']}/objects/#{pid}/datastreams/#{datastream_id}/content"
    end

    # create an image tag from an IIIF image server
    def iiif_image_tag(image_pid, options)
      image_tag(iiif_image_url(image_pid, options),
                :alt => options[:alt].presence,
                :class => options[:class].presence)
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
        height = iiif_info["height"].to_i
        width = iiif_info["width"].to_i
        aspect_ratio = (width.to_f / height.to_f).to_f
        img_metadata = {height: height, width: width, aspect_ratio: aspect_ratio}
      else
        img_metadata = {height: 0, width: 0, aspect_ratio: 0}
      end
      img_metadata
    end

    def insert_opengraph_markup
      if controller_name == 'catalog' && action_name == 'show'
        content_for(:head) do
          render :partial=>'/catalog/opengraph', :locals => {:document => @document}
        end
      end
    end

    def insert_google_analytics
      if Rails.env.to_s == 'production'
        content_for(:head) do
          render :partial=>'/layouts/google_analytics'
        end
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
