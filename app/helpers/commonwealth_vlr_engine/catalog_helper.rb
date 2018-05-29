module CommonwealthVlrEngine
  module CatalogHelper
    include Blacklight::CatalogHelperBehavior

    # returns the CC license terms code for use in URLs, etc.
    def cc_terms_code(license)
      license.match(/\s[BYNCDSA-]{2,}/).to_s.strip.downcase
    end

    # returns a link to a CC license
    def cc_url(license)
      terms_code = cc_terms_code(license)
      "http://creativecommons.org/licenses/#{terms_code}/3.0"
    end

    # return the image url for the collection gallery view document
    # size = pixel length of square IIIF-created image
    def collection_gallery_url document, size
      exemplary_image_pid = document[:exemplary_image_ssi]
      if exemplary_image_pid
        if exemplary_image_pid.match(/oai/) ||
           document['exemplary_image_iiif_bsi'] == false
          datastream_disseminator_url(exemplary_image_pid,'thumbnail300')
        else
          iiif_square_img_path(exemplary_image_pid, size)
        end
      else
        collection_icon_path
      end
    end

    def collection_icon_path
      'commonwealth-vlr-engine/dc_collection-icon.png'
    end

    def create_thumb_img_element(document, img_class=[])
      image_classes = img_class.class == Array ? img_class.join(' ') : ''
      image_tag(thumbnail_url(document),
                :alt => document[blacklight_config.index.title_field.to_sym],
                :class => image_classes)
    end

    # determine whether to render the 'show more' expand/collapse link in catalog#show metadata display
    def expand_metadata_link?(document)
      keys_to_eval = document.keys
      keys_to_eval.delete('identifier_uri_ss')
      return true if !keys_to_eval.grep(/note/).empty? || !keys_to_eval.grep(/identifier/).empty?
      # other fields, roughly in order of how often they appear in metadata records
      other_expand_fields = %w(lang_term_ssim pubplace_tsim local_accession_id_tsim publisher_tsim subject_scale_tsim
                               edition_tsim table_of_contents_tsi classification_tsim related_item_isreferencedby_ssm)
      other_expand_fields.each do |field_key|
        return true if keys_to_eval.include? field_key
      end
      false
    end

    def extra_body_classes
      @extra_body_classes ||= ['blacklight-' + controller_name, 'blacklight-' + [controller_name, controller.action_name].join('-')]
      # if this is the home page
      if controller_name == 'pages' && action_name =='home'
        @extra_body_classes.push('blacklight-home')
      else
        @extra_body_classes
      end
    end

    def has_image_files? files_hash
      files_hash[:images].present?
    end

    def image_file_pids images_hash
      image_file_pids = []
      images_hash.each do |image_file|
        image_file_pids << image_file['id']
      end
      image_file_pids
    end

    # render collection name as a link in catalog#index list view
    def index_collection_link options={}
      setup_collection_links(options[:document]).join(' / ').html_safe
    end


    # render the date in the catalog#index list view
    def index_date_value options={}
      render_mods_dates(options[:document]).first
    end

    # render institution name as a link in catalog#index list view
    def index_institution_link options={}
      link_to(options[:value].first,
              institution_path(:id => options[:document][:institution_pid_ssi]))
    end

    # render the collection/institution icon if necessary
    def index_relation_base_icon document
      if document[blacklight_config.view_config(document_index_view_type).display_type_field]
        display_type = document[blacklight_config.view_config(document_index_view_type).display_type_field].downcase
        if controller_name == 'catalog' && (display_type == 'collection' || display_type == 'institution')
          image_tag("commonwealth-vlr-engine/dc_#{display_type}-icon.png", alt: "#{display_type} icon", class: "index-title-icon #{display_type}-icon")
        else
          ''
        end
      end
    end

    # return the URL of an image to display in the catalog#index slideshow view
    def index_slideshow_img_url document
      if document[:exemplary_image_ssi] && !document[blacklight_config.flagged_field.to_sym]
        if document[blacklight_config.index.display_type_field.to_sym] == 'OAIObject' || document[:exemplary_image_ssi].match(/oai/)
          thumbnail_url(document)
        else
          iiif_image_url(document[:exemplary_image_ssi], {:size => ',500'})
        end
      elsif document[:type_of_resource_ssim]
        render_object_icon_path(document[:type_of_resource_ssim].first)
      elsif document[blacklight_config.index.display_type_field.to_sym] == 'Collection'
        collection_icon_path
      elsif document[blacklight_config.index.display_type_field.to_sym] == 'Institution'
        institution_icon_path
      else
        render_object_icon_path(nil)
      end
    end

    # determine the 'truncate' length based on catalog#index view type
    def index_title_length
      case params[:view]
        when 'list'
          170
        when 'masonry'
          89
        else
          130
      end
    end

    def institution_icon_path
      'commonwealth-vlr-engine/dc_institution-icon.png'
    end

    # link to items starting with a specific letter
    def link_to_az_value(letter, field, search_path, link_class=nil)
      new_params = params.except(:controller, :action, :q, :page)
      new_params[:q] = "#{field}:#{letter}*"
      link_to(letter,
              self.send(search_path, new_params),
              class: link_class)
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

    # insert an icon and link to CC licenses
    def render_cc_license(license)
      terms_code = cc_terms_code(license)
      link_to(image_tag("//i.creativecommons.org/l/#{terms_code}/3.0/80x15.png",
                        :alt => 'CC ' + terms_code.upcase + ' icon',
                        :class => 'cc_license_icon'),
              cc_url(license),
              :rel => 'license',
              :id => 'cc_license_link',
              :target => '_blank')
    end

    # output properly formatted full title, with subtitle, parallel title, etc.
    def render_full_title(document)
      title_output = ''
      if document[blacklight_config.index.title_field.to_sym]
        title_output << document[blacklight_config.index.title_field.to_sym]
        if document[:subtitle_tsim]
          title_output << " : #{document[:subtitle_tsim].first}"
        end
        if document[:title_info_partnum_tsi]
          title_output << ". #{document[:title_info_partnum_tsi]}"
        end
        if document[:title_info_partname_tsi]
          title_output << ". #{document[:title_info_partname_tsi]}"
        end
        if document[:title_info_primary_trans_tsim]
          document[:title_info_primary_trans_tsim].each do |parallel_title|
            title_output << " = #{parallel_title}"
          end
        end
      else
        title_output << document.id
      end
      title_output.gsub(/[^\.]\.\.[^\.]/, '.').squish
    end

    # render metadata for <mods:hierarchicalGeographic> subjects from GeoJSON
    def render_hiergo_subject(geojson_feature, separator, separator_class=nil)
      output_array = []
      hiergeo_hash = JSON.parse(geojson_feature).symbolize_keys[:properties]
      hiergeo_hash.each_key do |k|
        if k == 'country' && hiergeo_hash[k] == 'United States'
          # display 'United States' only if no other values
          output_array << link_to_facet(hiergeo_hash[k], 'subject_geographic_ssim') if hiergeo_hash.length == 1
        elsif k == 'county'
          output_array << link_to_facet("#{hiergeo_hash[k]} (county)", 'subject_geographic_ssim')
        elsif k == 'island' || k == 'area' || k == 'province' || k == 'territory' || k == 'region'
          output_array << link_to_facet(hiergeo_hash[k], 'subject_geographic_ssim') + " (#{k.to_s})"
        elsif k == 'other'
          place_type = hiergeo_hash[k].scan(/\([a-z\s]*\)/).last
          place_name = hiergeo_hash[k].gsub(/#{place_type}/,'').gsub(/\s\(\)\z/,'')
          output_array << link_to_facet(place_name, 'subject_geographic_ssim') + " #{place_type.to_s}"
        else
          output_array << link_to_facet(hiergeo_hash[k], 'subject_geographic_ssim')
        end
      end
      output_array.join(content_tag(:span, separator, :class => separator_class)).html_safe
    end

    def render_item_breadcrumb(document)
      if document[:collection_pid_ssm]
        setup_collection_links(document).sort.join(' / ').html_safe
      end
    end

    # output properly formatted title with volume info, but no subtitle
    def render_main_title(document)
      title_output = ''
      if document[blacklight_config.index.title_field.to_sym]
        title_output << document[blacklight_config.index.title_field.to_sym]
        if document[:title_info_partnum_tsi]
          title_output << ". #{document[:title_info_partnum_tsi]}"
        end
        if document[:title_info_partname_tsi]
          title_output << ". #{document[:title_info_partname_tsi]}"
        end
      else
        title_output << document.id
      end
      title_output.gsub(/[^\.]\.\.[^\.]/, '.').squish
    end

    # render the 'more like this' search link if doc has subjects
    def render_mlt_search_link(document)
      if document[:subject_facet_ssim] || document[:subject_geo_city_ssim] || document[:related_item_host_ssim]
        content_tag :div, id: 'more_mlt_link_wrapper' do
          link_to t('blacklight.more_like_this.more_mlt_link'),
                  search_catalog_path(mlt_id: document.id),
                  id: 'more_mlt_link'
        end
      end
    end

    # returns an array of properly-formatted date values
    def render_mods_dates (document)
      date_values = []
      document[:date_start_tsim].each_with_index do |start_date,index|
        date_type = document[:date_type_ssm] ? document[:date_type_ssm][index] : nil
        date_qualifier = document[:date_start_qualifier_ssm] ? document[:date_start_qualifier_ssm][index] : nil
        date_end = document[:date_end_tsim] ? document[:date_end_tsim][index] : nil
        date_values << render_mods_date(start_date, date_end, date_qualifier, date_type)
      end
      date_values
    end

    # returns a properly-formatted date value as a string
    def render_mods_date (date_start, date_end = nil, date_qualifier = nil, date_type = nil)
      prefix = ''
      suffix = ''
      date_start_suffix = ''
      if date_qualifier && date_qualifier != 'nil'
        prefix = date_qualifier == 'approximate' ? '[ca. ' : '['
        suffix = date_qualifier == 'questionable' ? '?]' : ']'
      end
      prefix << '(c) ' if date_type == 'copyrightDate'
      if date_end && date_end != 'nil'
        date_start_suffix = '?' if date_qualifier == 'questionable'
        prefix + normalize_date(date_start) + date_start_suffix + t('blacklight.metadata_display.date_range_connector') + normalize_date(date_end) + suffix
      else
        prefix + normalize_date(date_start) + suffix
      end
    end

    # have to override to display non-typical constraints
    # (e.g. coordinates, mlt, range limit, advanced search)
    # need this until:
    # https://github.com/projectblacklight/blacklight_advanced_search/issues/53
    # https://github.com/projectblacklight/blacklight-maps/issues/84
    # https://github.com/projectblacklight/blacklight_range_limit/issues/49
    # are resolved
    def render_search_to_page_title(params)
      # this is ugly, but easiest way to deal with it; too many gems to try and solve it all here
      html_constraints = render_search_to_s(params).gsub(/<span class="filterValues">/,' ')
      html_constraints = html_constraints.gsub(/<\/span>[\s]*<span class="constraint">/,' / ')
      sanitize(html_constraints, :tags=>[])

      ## TODO: remove above and uncomment lines below after all issues have been resolved with
      ##       blacklight_advanced_search, blacklight_range_limit, and blacklight-maps
      # constraints = [render_search_to_page_title_mlt(params), super(params)]
      # constraints.reject { |item| item.blank? }.join(' / ')
    end

    # TODO: uncomment and write spec after issues identified with render_search_to_page_title resolved
    #def render_search_to_page_title_mlt(params)
    #  return "".html_safe if params[:mlt_id].blank?
    #  "#{t('blacklight.search.filters.label', :label => t('blacklight.more_like_this.constraint_label'))} #{h(params[:mlt_id])}"
    #end

    def render_mods_xml_record(document_id)
      mods_xml_file_path = datastream_disseminator_url(document_id, 'descMetadata')
      mods_response = Typhoeus::Request.get(mods_xml_file_path)
      mods_xml_text = REXML::Document.new(mods_response.body)
    end

    def render_volume_title(document)
      vol_title_info = [document[:title_info_partnum_tsi], document[:title_info_partname_tsi]]
      if vol_title_info[0]
        vol_title_info[1] ? vol_title_info[0].capitalize + ': ' + vol_title_info[1] : vol_title_info[0].capitalize
      elsif vol_title_info[1]
        vol_title_info[1].capitalize
      else
        render_main_title(document)
      end
    end

    # creates an array of collection links
    # for display on catalog#index list view and catalog#show breadcrumb
    def setup_collection_links(document, link_class=nil)
      coll_hash = {}
      0.upto document[:collection_pid_ssm].length-1 do |index|
        coll_hash[document[blacklight_config.collection_field.to_sym][index]] = document[:collection_pid_ssm][index]
      end
      coll_links = []
      coll_hash.sort.each do |coll_array|
        coll_links << link_to(coll_array[0],
                              collection_path(:id => coll_array[1]),
                              :class => link_class.presence)
      end
      coll_links
    end

    # create a list of names and roles to be displayed
    def setup_names_roles(document)
      names = []
      roles = []
      multi_role_indices = []
      name_fields = [document[:name_personal_tsim], document[:name_corporate_tsim], document[:name_generic_tsim]]
      role_fields = [document[:name_personal_role_tsim], document[:name_corporate_role_tsim], document[:name_generic_role_tsim]]
      name_fields.each_with_index do |name_field,name_field_index|
        if name_field
          0.upto name_field.length-1 do |index|
            names << name_field[index]
            if role_fields[name_field_index] && role_fields[name_field_index][index]
              roles << role_fields[name_field_index][index].strip
            else
              roles << 'Creator'
            end
          end
        end
      end
      roles.each_with_index do |role,index|
        if /[\|]{2}/.match(role)
          multi_roles = role.split('||')
          multi_role_name = names[index]
          multi_role_indices << index
          multi_roles.each { |multi_role| roles << multi_role }
          0.upto multi_roles.length-1 do
            names << multi_role_name
          end
        end
      end
      unless multi_role_indices.empty?
        multi_role_indices.reverse.each do |index|
          names.delete_at(index)
          roles.delete_at(index)
        end
      end
      return names,roles
    end

    def should_autofocus_on_search_box?
      (controller.is_a? Blacklight::Catalog and
          action_name == "index" and
          params[:q].to_s.empty? and
          params[:f].to_s.empty?) or
          (controller.is_a? PagesController and action_name == 'home')
    end

    # LOCAL OVERRIDE: don't want to pull thumbnail url from Solr
    def thumbnail_url document
      if document[:exemplary_image_ssi] && !document[blacklight_config.flagged_field.to_sym]
        datastream_disseminator_url(document[:exemplary_image_ssi], 'thumbnail300')
      elsif document[:type_of_resource_ssim]
        render_object_icon_path(document[:type_of_resource_ssim].first)
      elsif document[blacklight_config.index.display_type_field.to_sym] == 'Collection'
        collection_icon_path
      elsif document[blacklight_config.index.display_type_field.to_sym] == 'Institution'
        institution_icon_path
      else
        render_object_icon_path(nil)
      end
    end

  end
end