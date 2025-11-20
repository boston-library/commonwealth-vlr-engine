# frozen_string_literal: true

# methods related to rendering metadata values
module CommonwealthVlrEngine
  module MetadataHelperBehavior
    # render the date in the catalog#index list view
    def index_date_value(options = {})
      options[:document][:date_tsim]&.first
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

    # output properly formatted title
    # if full = true, include subtitle, parallel title, etc.
    # if full = false, output with volume info, but no subtitle or parallel title
    def render_title(document, full = true)
      title_output = ''
      if document[blacklight_config.index.title_field.field]
        title_output += document[blacklight_config.index.title_field.field]
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
      title_output = title_output.gsub(/\.\./, '.') if title_output.match?(regex)
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

    def render_constituent(document)
      document[:related_item_constituent_tsim].map { |c| c.split('--').map(&:strip).join('<br>') }.join('<br>')
    end

    # return MODS XML (serialized in Solr as gzipped Base64 encoded String)
    def render_mods_xml_record(document)
      return '' unless document['mods_xml_ss']

      mods_data = Zlib::Inflate.inflate(Base64.decode64(document['mods_xml_ss']))
      REXML::Document.new(mods_data)
    end

    def render_toc(document)
      document[:table_of_contents_tsi].split('--').map(&:strip).join('<br>')
    end

    # create a list of names and roles to be displayed
    # @param [SolrDoument] document
    # @return [Hash] { 'role1' => ['name1', 'name2'], 'role2' => ['name3'] }
    def setup_names_roles(document)
      roles_names = {}
      role_field_values = document[:name_role_tsim]
      document[:name_tsim].each_with_index do |name, index|
        roles_for_name = (role_field_values[index] || 'Creator').split('||')
        roles_for_name.each do |rfn|
          roles_names[rfn] ||= []
          roles_names[rfn] << name
        end
      end
      roles_names.each_value { |v| v.sort! }.sort.to_h
    end

    def show_abstract(document)
      document[:abstract_tsi].gsub(/<br\/><br\/>/, '<br>')
    end
  end
end
