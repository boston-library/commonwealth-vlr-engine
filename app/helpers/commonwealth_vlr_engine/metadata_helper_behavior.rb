# frozen_string_literal: true

# methods related to rendering metadata values
module CommonwealthVlrEngine
  module MetadataHelperBehavior
    # determine whether to render the 'show more' expand/collapse link in catalog#show metadata display
    def expand_metadata_link?(document)
      keys_to_eval = document.keys
      keys_to_eval.delete('identifier_uri_ss')
      return true if !keys_to_eval.grep(/note/).empty? || !keys_to_eval.grep(/identifier/).empty?

      # other fields, roughly in order of how often they appear in metadata records
      other_expand_fields = %w(lang_term_ssim pubplace_tsi publisher_tsi scale_tsim projection_tsi
                               edition_name_tsi table_of_contents_tsi table_of_contents_url_ss
                               related_item_constituent_tsim related_item_other_format_tsim
                               related_item_references_ssm related_item_review_ssm related_item_isreferencedby_ssm)
      other_expand_fields.each do |field_key|
        return true if keys_to_eval.include? field_key
      end
      false
    end

    # render the date in the catalog#index list view
    def index_date_value(options = {})
      options[:document][:date_tsim]&.first
    end

    def normalize_date(date)
      if date.length == 10
        Date.parse(date).strftime('%B %-d, %Y')
      elsif date.length == 7
        Date.parse(date + '-01').strftime('%B %Y')
      else
        date
      end
    end

    def date_qualifier(date_type)
      case date_type
      when 'dateCreated'
        'created'
      when 'dateIssued'
        'issued'
      when 'copyrightDate'
        'copyright'
      else
        ''
      end
    end

    # render metadata for <mods:hierarchicalGeographic> subjects from GeoJSON
    def render_hiergo_subject(geojson_feature, separator, separator_class = nil)
      output_array = []
      hiergeo_hash = JSON.parse(geojson_feature).symbolize_keys[:properties]
      hiergeo_hash.each_key do |k|
        # only display continent if there are no other values
        if k == 'continent'
          output_array << link_to_facet(hiergeo_hash[k], 'subject_geographic_sim') if hiergeo_hash.length == 1
        elsif k == 'country' && hiergeo_hash[k] == 'United States'
          # display 'United States' only if no other values besides continent
          output_array << link_to_facet(hiergeo_hash[k], 'subject_geographic_sim') if hiergeo_hash.length == 2
        elsif k == 'county'
          output_array << link_to_facet("#{hiergeo_hash[k]} (county)", 'subject_geographic_sim')
        elsif k == 'island' || k == 'area' || k == 'province' || k == 'territory' || k == 'region'
          output_array << link_to_facet(hiergeo_hash[k], 'subject_geographic_sim') + " (#{k})"
        elsif k == 'other'
          place_type = hiergeo_hash[k].scan(/\([a-z\s]*\)/).last
          place_name = hiergeo_hash[k].gsub(/#{place_type}/, '').gsub(/\s\(\)\z/, '')
          output_array << link_to_facet(place_name, 'subject_geographic_sim') + " #{place_type}"
        else
          output_array << link_to_facet(hiergeo_hash[k], 'subject_geographic_sim')
        end
      end
      output_array.join(content_tag(:span, separator, :class => separator_class)).html_safe
    end

    # returns an array of properly-formatted date values
    # DEPRECATED
    # TODO: remove this once we're sure we don't need it anywhere
    # def render_mods_dates (document)
    #   date_values = []
    #   document[:date_tsim].each_with_index do |start_date, index|
    #     date_type = document[:date_type_ssm] ? document[:date_type_ssm][index] : nil
    #     date_qualifier = document[:date_start_qualifier_ssm] ? document[:date_start_qualifier_ssm][index] : nil
    #     date_end = document[:date_end_tsim] ? document[:date_end_tsim][index] : nil
    #     date_values << render_mods_date(start_date, date_end, date_qualifier, date_type)
    #   end
    #   date_values
    # end
    #
    # # returns a properly-formatted date value as a string
    # def render_mods_date (date_start, date_end = nil, date_qualifier = nil, date_type = nil)
    #   prefix = ''
    #   suffix = ''
    #   date_start_suffix = ''
    #   if date_qualifier && date_qualifier != 'nil'
    #     prefix = date_qualifier == 'approximate' ? '[ca. ' : '['
    #     suffix = date_qualifier == 'questionable' ? '?]' : ']'
    #   end
    #   prefix += '(c) ' if date_type == 'copyrightDate'
    #   if date_end && date_end != 'nil'
    #     date_start_suffix = '?' if date_qualifier == 'questionable'
    #     prefix + normalize_date(date_start) + date_start_suffix + t('blacklight.metadata_display.date_range_connector') + normalize_date(date_end) + suffix
    #   else
    #     prefix + normalize_date(date_start) + suffix
    #   end
    # end

    # output properly formatted title
    # if full = true, include subtitle, parallel title, etc.
    # if full = false, output with volume info, but no subtitle or parallel title
    def render_title(document, full = true)
      title_output = ''
      if document[blacklight_config.index.title_field.to_sym]
        title_output += document[blacklight_config.index.title_field.to_sym]
        title_output += " : #{document[:title_info_primary_subtitle_tsi]}" if document[:title_info_primary_subtitle_tsi] && full
        title_output += ". #{document[:title_info_partnum_tsi]}" if document[:title_info_partnum_tsi]
        title_output += ". #{document[:title_info_partname_tsi]}" if document[:title_info_partname_tsi]
        if document[:title_info_primary_trans_tsim] && full
          document[:title_info_primary_trans_tsim].each do |parallel_title|
            title_output += " = #{parallel_title}"
          end
        end
      else
        title_output = document.id
      end
      regex = /[^\.]\.\.[^\.]/ # double periods, but not ellipsis
      title_output.gsub!(/\.\./, '.') if title_output.match?(regex)
      title_output.squish
    end

    # output properly formatted alternative title
    def render_alt_title(document, index)
      alt_title_output = ''
      alt_title_output += document['title_info_alternative_tsim'][index]
      if document['title_info_other_subtitle_tsim'] &&
          document['title_info_other_subtitle_tsim'][index].present?
        alt_title_output += " : #{document['title_info_other_subtitle_tsim'][index]}"
      end
      alt_title_output
    end

    # return MODS XML (serialized in Solr as gzipped Base64 encoded String)
    def render_mods_xml_record(document)
      return '' unless document['mods_xml_ss']

      mods_data = Zlib::Inflate.inflate(Base64.decode64(document['mods_xml_ss']))
      REXML::Document.new(mods_data)
    end

    # create a list of names and roles to be displayed
    def setup_names_roles(document)
      names = []
      roles = []
      multi_role_indices = []
      role_field_values = document[:name_role_tsim]
      document[:name_tsim].each_with_index do |name, index|
        names << name
        if role_field_values[index]
          roles << role_field_values[index].strip
        else
          roles << 'Creator'
        end
      end
      roles.each_with_index do |role, index|
        next unless role.match?(/[\|]{2}/)

        multi_roles = role.split('||')
        multi_role_name = names[index]
        multi_role_indices << index
        multi_roles.each { |multi_role| roles << multi_role }
        0.upto(multi_roles.length - 1) do
          names << multi_role_name
        end
      end
      unless multi_role_indices.empty?
        multi_role_indices.reverse_each do |index|
          names.delete_at(index)
          roles.delete_at(index)
        end
      end
      [names, roles]
    end
  end
end
