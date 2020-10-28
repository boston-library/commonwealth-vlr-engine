# frozen_string_literal: true

module BlacklightIiifSearch
  module AnnotationBehavior
    # include so we can use #datastream_disseminator_url
    include CommonwealthVlrEngine::ApplicationHelper

    def annotation_id
      "#{parent_document[:identifier_uri_ss]}/annotation/#{document[:id].split(':')[1]}##{hl_index}"
    end

    def canvas_uri_for_annotation
      "#{parent_document[:identifier_uri_ss]}/canvas/#{document[:id].split(':')[1]}" + coordinates
    end

    # return a string like "#xywh=100,100,250,20"
    # corresponding to coordinates of query term on image
    # local implementation expected
    def coordinates
      default = '#xywh=0,0,0,0'
      return default if query.blank?

      coords_json = fetch_and_parse_coords
      if coords_json && coords_json['words']
        matches = coords_json['words'].select { |k, _v| k.downcase =~ /#{query.downcase}/ }
        return default unless matches

        djvu_coords_array = matches.values.flatten(1)[hl_index]
        return default unless djvu_coords_array

        width = djvu_coords_array[2] - djvu_coords_array[0]
        height = djvu_coords_array[1] - djvu_coords_array[3]
        "#xywh=#{djvu_coords_array[0]},#{djvu_coords_array[3]},#{width},#{height}"
      else
        default
      end
    end

    def fetch_and_parse_coords
      coords_url = datastream_disseminator_url(document[:id], 'djvuCoords')
      Rails.cache.fetch("#{document[:id]}_djvuCoords", expires_in: 1.day) do
        begin
          JSON.parse(Typhoeus::Request.get(coords_url).body)
        rescue JSON::ParserError
          nil
        end
      end
    end
  end
end
