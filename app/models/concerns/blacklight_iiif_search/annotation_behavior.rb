# frozen_string_literal: true

module BlacklightIiifSearch
  module AnnotationBehavior
    # include so we can use #filestream_disseminator_url
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
      # 1,1,1,1 works better than 0,0,0,0, latter leads to weird behavior in Universal Viewer
      default = '#xywh=1,1,1,1'
      return default if query.blank?

      coords_json = fetch_and_parse_coords
      if coords_json && coords_json['words']
        matches = coords_json['words'].select { |k, _v| k.gsub(/[\.,:;?!)]\z/, '') == query }
        return default unless matches

        # when multi-word query, hl_index may not exist for term, so use the highest index available
        term_coords_array = nil
        hl_term_index.downto(0) do |h_i|
          next if term_coords_array

          term_coords_array = matches.values.flatten(1)[h_i]
        end

        return default unless term_coords_array

        width = term_coords_array[2] - term_coords_array[0]
        height = term_coords_array[3] - term_coords_array[1]
        "#xywh=#{term_coords_array[0]},#{term_coords_array[1]},#{width},#{height}"
      else
        default
      end
    end

    def fetch_and_parse_coords
      coords_url = filestream_disseminator_url(document[:storage_key_base_ss], 'text_coordinates_access')
      Rails.cache.fetch("#{document[:id]}_text_coordinates", expires_in: 1.day) do
        begin
          JSON.parse(Typhoeus::Request.get(coords_url).body)
        rescue JSON::ParserError
          nil
        end
      end
    end
  end
end
