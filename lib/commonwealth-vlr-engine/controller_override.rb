module CommonwealthVlrEngine
  module ControllerOverride
    extend ActiveSupport::Concern

    included do

      self.send(:include, CommonwealthVlrEngine::Finder)
      self.send(:include, CommonwealthVlrEngine::RenderConstraintsOverride)
      self.send(:helper, CommonwealthVlrEngine::RenderConstraintsOverride)

      # add BlacklightAdvancedSearch
      self.send(:include, BlacklightAdvancedSearch::Controller)

      # add BlacklightMaps
      self.send(:include, BlacklightMaps::ControllerOverride)

      before_filter :get_object_files, :only => [:show]
      before_filter :set_nav_context, :only => [:index]
      before_filter :mlt_search, :only => [:index]
      before_filter :add_institution_fields, :only => [:index, :facet]

      helper_method :has_volumes?

      remove_default_tool_configs
      add_commonwealthvlr_default_tool

      # all the commonwealth-vlr-engine CatalogController config stuff goes here
      configure_blacklight do |config|

        #set default per-page
        config.default_per_page = 20

        #blacklight-gallery stuff
        config.view.gallery.default = true
        config.view.gallery.partials = [:index_header]
        config.view.gallery.icon_class = 'glyphicon-th-large'
        config.view.masonry.partials = [:index_header]
        config.view.slideshow.partials = [:index]

        # blacklight-maps stuff
        config.view.maps.geojson_field = 'subject_geojson_facet_ssim'
        config.view.maps.coordinates_field = 'subject_coordinates_geospatial'
        config.view.maps.placename_field = 'subject_geographic_ssim'
        config.view.maps.maxzoom = 14
        config.view.maps.show_initial_zoom = 12
        config.view.maps.facet_mode = 'geojson'

        # helper that returns thumbnail URLs
        config.index.thumbnail_method = :create_thumb_img_element

        # configuration for search results/index views
        config.index.partials = [:thumbnail, :index_header, :index]

        #Actions configuration
        #blacklight_config.show.document_actions
        config.index.document_actions.delete(:bookmark) # don't show default bookmark control
        config.show.document_actions.delete(:bookmark) # don't show default bookmark control

        config.show.document_actions.delete(:email)
        #config.add_show_tools_partial :email, if: Proc.new { |context, config, options| options[:document].respond_to?( :to_email_text ) and !options[:document][:active_fedora_model_suffix_ssi].include?['Collection','Institution','OAICollection','SystemCollection'] }, partial: 'show_sharing_tools'
        #config.add_show_tools_partial :cite, if: Proc.new { |context, config, options| !options[:document]['active_fedora_model_suffix_ssi'].include?['Collection','Institution','OAICollection','SystemCollection'] }, partial: 'show_cite_tools'


        # solr field configuration for document/show views
        config.show.title_field = 'title_info_primary_tsi'
        config.show.display_type_field = 'active_fedora_model_suffix_ssi'

        # solr field for flagged/inappropriate content
        config.flagged_field = 'flagged_content_ssi'

        # advanced search configuration
        config.advanced_search = {
            qt: 'search',
            url_key: 'advanced',
            query_parser: 'edismax',
            form_solr_parameters: {
                'facet.field' => ['genre_basic_ssim', 'collection_name_ssim'],
                'facet.limit' => -1, # return all facet values
                'facet.sort' => 'index' # sort by byte order of values
            }
        }

        # collection name field
        config.collection_field = 'collection_name_ssim'
        # institution name field
        config.institution_field = 'institution_name_ssim'

        # book stuff
        config.ocr_search_field = 'ocr_tsiv'
        config.page_num_field = 'page_num_label_ssi'

        config.default_solr_params = {:qt => 'search', :rows => 20}

        # solr field configuration for search results/index views
        config.index.title_field = 'title_info_primary_tsi'
        config.index.display_type_field = 'active_fedora_model_suffix_ssi'

        # solr fields that will be treated as facets by the blacklight application
        config.add_facet_field 'subject_facet_ssim', label: 'Topic', limit: 8, sort: 'count', collapse:  false
        config.add_facet_field 'subject_geographic_ssim', label: 'Place', limit: 8, sort: 'count', collapse:  false
        config.add_facet_field 'date_facet_ssim', label: 'Date', limit: 8, sort: 'index', collapse:  false
        config.add_facet_field 'genre_basic_ssim', label: 'Format', limit: 8, sort: 'count', helper_method: :render_format, collapse:  false
        config.add_facet_field 'collection_name_ssim', label: 'Collection', limit: 8, sort: 'count', collapse:  false
        # link_to_facet fields (not in facets sidebar of search results)
        config.add_facet_field 'related_item_host_ssim', label: 'Collection', include_in_request: false # Collection (local)
        config.add_facet_field 'genre_specific_ssim', label: 'Genre', include_in_request: false
        config.add_facet_field 'related_item_series_ssim', label: 'Series', limit: 300, sort: 'index', include_in_request: false
        config.add_facet_field 'related_item_subseries_ssim', label: 'Subseries', include_in_request: false
        config.add_facet_field 'related_item_subsubseries_ssim', label: 'Sub-subseries', include_in_request: false
        config.add_facet_field 'institution_name_ssim', label: 'Institution', include_in_request: false
        config.add_facet_field 'name_facet_ssim', label: 'Name', include_in_request: false
        # facet for blacklight-maps catalog#index map view
        # have to use '-2' to get all values
        # because Blacklight::RequestBuilders#solr_facet_params adds '+1' to value
        config.add_facet_field 'subject_geojson_facet_ssim', limit: -2, label: 'Coordinates', show: false

        # solr fields to be displayed in the index (search results) view
        config.add_index_field 'genre_basic_ssim', label: 'Format', helper_method: :render_format_index
        config.add_index_field 'collection_name_ssim', label: 'Collection', helper_method: :index_collection_link
        config.add_index_field 'date_start_tsim', label: 'Date', helper_method: :index_date_value

        # "fielded" search configuration. Used by pulldown among other places.
        config.add_search_field('all_fields') do |field|
          field.label = 'All Fields'
          field.solr_parameters = { :'spellcheck.dictionary' => 'default' }
        end

        config.add_search_field('title') do |field|
          field.solr_parameters = { :'spellcheck.dictionary' => 'default' }
          field.solr_local_parameters = {
              qf: '$title_qf',
              pf: '$title_pf'
          }
        end

        config.add_search_field('subject') do |field|
          field.solr_parameters = { :'spellcheck.dictionary' => 'default' }
          field.qt = 'search'
          field.solr_local_parameters = {
              qf: '$subject_qf',
              pf: '$subject_pf'
          }
        end

        config.add_search_field('place') do |field|
          field.solr_parameters = { :'spellcheck.dictionary' => 'default' }
          field.solr_local_parameters = {
              qf: '$place_qf',
              pf: '$place_pf'
          }
        end

        config.add_search_field('creator') do |field|
          field.solr_parameters = { :'spellcheck.dictionary' => 'default' }
          field.solr_local_parameters = {
              qf: '$author_qf',
              pf: '$author_pf'
          }
        end

        # "sort results by" select (pulldown)
        config.add_sort_field 'score desc, title_info_primary_ssort asc', label: 'relevance'
        config.add_sort_field 'title_info_primary_ssort asc, date_start_dtsi asc', label: 'title'
        config.add_sort_field 'date_start_dtsi asc, title_info_primary_ssort asc', label: 'date (asc)'
        config.add_sort_field 'date_start_dtsi desc, title_info_primary_ssort asc', label: 'date (desc)'

      end

      # displays the MODS XML record. copied from blacklight-marc 'librarian_view'
      # for some reason won't work if not in the 'included' block
      def metadata_view
        @response, @document = fetch(params[:id])

        respond_to do |format|
          format.html
          format.js { render :layout => false }
        end
      end

      # modify facet settings for Collections#show and Institutions#show
      def relation_base_blacklight_config
        # don't show collection facet
        blacklight_config.facet_fields['collection_name_ssim'].show = false
        blacklight_config.facet_fields['collection_name_ssim'].if = false
        # collapse remaining facets
        blacklight_config.facet_fields['subject_facet_ssim'].collapse = true
        blacklight_config.facet_fields['subject_geographic_ssim'].collapse = true
        blacklight_config.facet_fields['date_facet_ssim'].collapse = true
        blacklight_config.facet_fields['genre_basic_ssim'].collapse = true
      end

    end

    # displays values and pagination links for Format field
    def formats_facet
      @nav_li_active = 'explore'
      @page_title = t('blacklight.formats.page_title', :application_name => t('blacklight.application_name'))

      @facet = blacklight_config.facet_fields['genre_basic_ssim']

      @response = get_facet_field_response(@facet.key, params, {"f.genre_basic_ssim.facet.limit" => -1})
      @display_facet = @response.aggregations[@facet.key]
      @pagination = facet_paginator(@facet, @display_facet)

      render :facet
    end

    # if this is 'more like this' search, solr id = params[:mlt_id]
    def mlt_search
      if params[:mlt_id]
        blacklight_config.search_builder_class = CommonwealthMltSearchBuilder
      end
    end

    # TODO: refactor how views access files/volumes/etc.
    def get_object_files
      @object_files = get_files(params[:id])
    end

    def set_nav_context
      @nav_li_active = 'search'
    end

    # add institutions if configured
    def add_institution_fields
      if t('blacklight.home.browse.institutions.enabled')
        blacklight_config.add_facet_field 'physical_location_ssim', label: 'Institution', limit: 8, sort: 'count', collapse:  false
        blacklight_config.add_index_field 'institution_name_ssim', label: 'Institution', helper_method: :index_institution_link
      end
    end

    # TODO: refactor how views access files/volumes/etc.
    # returns the child volumes for Book objects (if they exist)
    # needs to be in this module because CommonwealthVlrEngine::Finder methods aren't accessible in helpers/views
    def has_volumes?(document)
      case document[blacklight_config.show.display_type_field.to_sym]
        when 'Book'
          volumes = get_volume_objects(document.id)
        else
          volumes = nil
      end
      volumes.presence
    end

    protected
    ##
    # When a user logs in, transfer any saved searches or bookmarks to the current_user
    def transfer_guest_user_actions_to_current_user
      return unless respond_to? :current_user and respond_to? :guest_user and current_user and guest_user
      current_user_searches = current_user.searches.pluck(:query_params)
      current_user_bookmarks = current_user.bookmarks.pluck(:document_id)

      guest_user.searches.reject { |s| current_user_searches.include?(s.query_params)}.each do |s|
        current_user.searches << s
        s.save!
      end

      guest_user.bookmarks.reject { |b| current_user_bookmarks.include?(b.document_id)}.each do |b|
        current_user.bookmarks << b
        b.save!
      end

      #Custom code to transfer over folders
      guest_user.folders.each do |folder|
        target_folder = current_user.folders.where(:title=>folder.title)
        if target_folder.blank?
          target_folder = current_user.folders.create({title: folder.title, description: folder.description, visibility: folder.visibility})
          target_folder.save!
        else
          target_folder = target_folder.first
        end
        folder.folder_items.each do |item_to_add|
          unless target_folder.has_folder_item(item_to_add.document_id)
            target_folder.folder_items.create(:document_id => item_to_add.document_id) and target_folder.touch
            target_folder.save!
          end
        end
      end

      # let guest_user know we've moved some bookmarks from under it
      guest_user.reload if guest_user.persisted?
    end

    module ClassMethods

      ##
      # There is a default configuration included that you can see at:
      # https://github.com/projectblacklight/blacklight/blob/d55d6f566d203a092f7f40987a37d8988df5500d/app/controllers/concerns/blacklight/default_component_configuration.rb
      #
      # It is included by Blacklight::Catalog that then is included by all local CatalogControllers. Simply disabling it
      # in the blacklight config block isn't feasible as that include re-adds those components on ever page view while
      # it seems the blacklight config block is only ever run once? Or could be some other reason.
      def remove_default_tool_configs opts = {}
        #Show actions to remove
        blacklight_config.show.document_actions.delete(:email)
        blacklight_config.show.document_actions.delete(:sms)
        blacklight_config.show.document_actions.delete(:bookmark)
        blacklight_config.show.document_actions.delete(:citation)

        #Index actions to remove
        blacklight_config.index.document_actions.delete(:bookmark)
      end


      def add_commonwealthvlr_default_tool opts = {}
        blacklight_config.add_show_tools_partial :add_this, partial: 'add_this', unless: Proc.new { |context, config, options| ['Collection','Institution','OAICollection','SystemCollection'].include?(options[:document]['active_fedora_model_suffix_ssi']) }
        blacklight_config.add_show_tools_partial :folder_items, partial: 'folder_item_control', unless: Proc.new { |context, config, options| ['Collection','Institution','OAICollection','SystemCollection'].include?(options[:document]['active_fedora_model_suffix_ssi']) }
        blacklight_config.add_show_tools_partial :custom_email, partial: 'show_sharing_tools', if: Proc.new { |context, config, options| options[:document].respond_to?( :to_email_text ) and !['Collection','Institution','OAICollection','SystemCollection'].include?(options[:document]['active_fedora_model_suffix_ssi']) }
        blacklight_config.add_show_tools_partial :cite, partial: 'show_cite_tools', unless: Proc.new { |context, config, options| ['Collection','Institution','OAICollection','SystemCollection'].include?(options[:document]['active_fedora_model_suffix_ssi']) }
      end
    end

  end

end