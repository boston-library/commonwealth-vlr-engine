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
      "http://creativecommons.org/licenses/#{terms_code}/4.0/"
    end

    # return the image url for the collection gallery view document
    # size = pixel length of square IIIF-created image
    def collection_gallery_url(document, size)
      exemplary_image_pid = document[:exemplary_image_ssi]
      if exemplary_image_pid
        if document[blacklight_config.hosting_status_field.to_sym] == 'harvested' || document['exemplary_image_iiif_bsi'] == false
          filestream_disseminator_url(document[:exemplary_image_key_base_ss], 'image_thumbnail_300')
        else
          iiif_image_url(exemplary_image_pid, { region: 'square', size: "#{size}," })
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
      other_expand_fields = %w(lang_term_ssim pubplace_tsi publisher_tsi scale_tsim projection_tsi
                               edition_name_tsi table_of_contents_tsi table_of_contents_url_ss
                               related_item_constituent_tsim related_item_other_format_tsim
                               related_item_references_ssm related_item_review_ssm related_item_isreferencedby_ssm)
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

    def has_image_files?(files_hash)
      files_hash[:image].present?
    end

    def has_video_files?(files_hash)
      files_hash[:video].present?
    end

    def image_file_pids(images)
      images.map { |i| i[:id] }
    end

    # render collection name as a link in catalog#index list view
    def index_collection_link options={}
      setup_collection_links(options[:document]).join(' / ').html_safe
    end


    # render the date in the catalog#index list view
    def index_date_value(options = {})
      options[:document][:date_tsim].first if options[:document][:date_tsim]
    end

    # render institution name as a link in catalog#index list view
    def index_institution_link options={}
      link_to(options[:value].first,
              institution_path(:id => options[:document][:institution_ark_id_ssi]))
    end

    # render the collection/institution icon if necessary
    def index_relation_base_icon document
      return unless document[blacklight_config.view_config(document_index_view_type).display_type_field]

      display_type = document[blacklight_config.view_config(document_index_view_type).display_type_field].downcase
      if controller_name == 'catalog' && (display_type == 'collection' || display_type == 'institution')
        image_tag("commonwealth-vlr-engine/dc_#{display_type}-icon.png", alt: "#{display_type} icon", class: "index-title-icon #{display_type}-icon")
      else
        ''
      end
    end

    # return the URL of an image to display in the catalog#index slideshow view
    def index_slideshow_img_url(document)
      if document[:exemplary_image_ssi] && document[blacklight_config.flagged_field.to_sym] != 'explicit'
        if document[blacklight_config.index.display_type_field.to_sym] == 'OAIObject' || document[:exemplary_image_ssi].match(/oai/)
          thumbnail_url(document)
        else
          iiif_image_url(document[:exemplary_image_ssi], { size: ',500' })
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

    # render reuse_allowed_ssi values for facet display
    def render_reuse(value)
      case value
      when 'no restrictions'
        'No known restrictions'
      when 'creative commons'
        'Creative Commons license'
      else
        'See item for details'
      end
    end

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

    def render_item_breadcrumb(document)
      if document[:collection_ark_id_ssim]
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
      title_output.gsub(/\.\./, '.').squish
    end

    # render the 'more like this' search link if doc has subjects
    def render_mlt_search_link(document)
      if document[:subject_facet_ssim] || document[:subject_geo_city_sim] || document[:related_item_host_ssim]
        content_tag :div, id: 'more_mlt_link_wrapper' do
          link_to t('blacklight.more_like_this.more_mlt_link'),
                  search_catalog_path(mlt_id: document.id),
                  id: 'more_mlt_link'
        end
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

    # creates an array of collection links
    # for display on catalog#index list view and catalog#show breadcrumb
    def setup_collection_links(document, link_class=nil)
      coll_hash = {}
      0.upto document[:collection_ark_id_ssim].length-1 do |index|
        coll_hash[document[blacklight_config.collection_field.to_sym][index]] = document[:collection_ark_id_ssim][index]
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

    def should_autofocus_on_search_box?
      (controller.is_a? Blacklight::Catalog and
          action_name == "index" and
          params[:q].to_s.empty? and
          params[:f].to_s.empty?) or
          (controller.is_a? PagesController and action_name == 'home')
    end

    # LOCAL OVERRIDE: don't want to pull thumbnail url from Solr
    def thumbnail_url(document)
      thumbnail_att_name = 'image_thumbnail_300'
      if document[:exemplary_image_ssi] && document[blacklight_config.flagged_field.to_sym] != 'explicit'
        if document[blacklight_config.index.display_type_field.to_sym] == 'Institution'
          attachment_json = JSON.parse(document[:attachments_ss])
          filestream_disseminator_url(attachment_json[thumbnail_att_name]['key'], thumbnail_att_name, true)
        else
          filestream_disseminator_url(document[:exemplary_image_key_base_ss], thumbnail_att_name)
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

    def show_explicit_warning?(document)
      document[blacklight_config.flagged_field.to_sym] == 'explicit'
    end

    def show_content_warning?(document)
      document[blacklight_config.flagged_field.to_sym] == 'offensive'
    end
  end
end