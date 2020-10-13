module CommonwealthVlrEngine
  module ControllerOverride
    extend ActiveSupport::Concern

    included do
      self.send(:include, CommonwealthVlrEngine::Finder)
      #self.send(:include, CommonwealthVlrEngine::RenderConstraintsOverride)
      #self.send(:helper, CommonwealthVlrEngine::RenderConstraintsOverride)

      # add BlacklightAdvancedSearch
      self.send(:include, BlacklightAdvancedSearch::Controller)

      # add BlacklightMaps
      self.send(:include, BlacklightMaps::Controller)

      # add BlacklightRangeLimit
      self.send(:include, BlacklightRangeLimit::ControllerOverride)

      # add BlacklightIiifSearch
      self.send(:include, BlacklightIiifSearch::Controller)

      # HEADS UP: these filters get inherited by any subclass of CatalogController
      before_action :get_object_files, only: [:show]
      before_action :mlt_results_for_show, only: [:show]
      before_action :set_nav_context, only: [:index]
      before_action :mlt_search, only: [:index]
      before_action :add_institution_fields, only: [:index, :facet]

      helper_method :has_volumes?
      # all the commonwealth-vlr-engine CatalogController config stuff goes here
      configure_blacklight do |config|

        #set default per-page
        config.default_per_page = 20

        # allow responses >100 rows
        config.max_per_page = 500

        #blacklight-gallery stuff
        config.view.gallery.default = true
        config.view.gallery.partials = [:index_header]
        # slideshow and masonry get ver little usage, deprecating
        # config.view.masonry.partials = [:index_header]
        # config.view.slideshow.partials = [:index]

        # blacklight-maps stuff
        config.view.maps.geojson_field = 'subject_geojson_facet_ssim'
        config.view.maps.coordinates_field = 'subject_coordinates_geospatial'
        config.view.maps.placename_field = 'subject_geographic_ssim'
        config.view.maps.maxzoom = 14
        config.view.maps.show_initial_zoom = 12
        config.view.maps.facet_mode = 'geojson'
        config.view.maps.spatial_query_dist = 0.2

        # helper that returns thumbnail URLs
        config.index.thumbnail_method = :create_thumb_img_element

        # configuration for search results/index views
        config.index.partials = [:thumbnail, :index_header, :index]

        # solr field configuration for document/show views
        config.show.title_field = 'title_info_primary_tsi'
        config.show.display_type_field = 'active_fedora_model_suffix_ssi'
        config.show.partials = [:show_breadcrumb, :show_header, :show]

        # solr field for flagged/inappropriate content
        config.flagged_field = 'flagged_content_ssi'

        # advanced search configuration
        config.advanced_search = {
            qt: 'search',
            url_key: 'advanced',
            query_parser: 'edismax',
            form_solr_parameters: {
                'facet.field' => ['genre_basic_ssim', 'collection_name_ssim'],
                'f.genre_basic_ssim.facet.limit' => -1, # return all facet values
                'f.collection_name_ssim.facet.limit' => -1,
                'f.genre_basic_ssim.facet.sort' => 'index', # sort by byte order of values
                'f.collection_name_ssim.facet.sort' => 'index'
            }
        }

        # fields for pseudo-objects (collection, institution, series)
        config.collection_field = 'collection_name_ssim'
        config.institution_field = 'institution_name_ssim'
        config.series_field = 'related_item_series_ssim'

        # book stuff
        config.ocr_search_field = 'ocr_tsiv'
        config.page_num_field = 'page_num_label_ssi'

        # configuration for Blacklight IIIF Content Search
        config.iiif_search = {
          full_text_field: 'ocr_tsiv',
          object_relation_field: 'is_image_of_ssim',
          supported_params: %w[q page]
        }

        config.default_solr_params = {:qt => 'search', :rows => 20}

        # solr field configuration for search results/index views
        config.index.title_field = 'title_info_primary_tsi'
        config.index.display_type_field = 'active_fedora_model_suffix_ssi'

        # solr fields that will be treated as facets by the blacklight application
        config.add_facet_field 'subject_facet_ssim', label: 'Topic', limit: 8, sort: 'count', collapse:  false
        config.add_facet_field 'subject_geographic_ssim', label: 'Place', limit: 8, sort: 'count', collapse:  false
        config.add_facet_field 'genre_basic_ssim', label: 'Format', limit: 8, sort: 'count', helper_method: :render_format, collapse:  false
        config.add_facet_field 'reuse_allowed_ssi', label: 'Available to use', limit: 8, sort: 'count', helper_method: :render_reuse,
                               collapse: false, solr_params: { 'facet.excludeTerms' => 'all rights reserved,contact host' }
        config.add_facet_field 'date_facet_yearly_ssim', :label => 'Date', :range => true, :collapse => false
        config.add_facet_field 'collection_name_ssim', label: 'Collection', limit: 8, sort: 'count', collapse:  false
        # link_to_facet fields (not in facets sidebar of search results)
        config.add_facet_field 'related_item_host_ssim', label: 'Collection', include_in_request: false # Collection (local)
        config.add_facet_field 'genre_specific_ssim', label: 'Genre', include_in_request: false
        config.add_facet_field 'related_item_series_ssim', label: 'Series', limit: 300, sort: 'index', include_in_request: false
        config.add_facet_field 'related_item_subseries_ssim', label: 'Subseries', include_in_request: false
        config.add_facet_field 'related_item_subsubseries_ssim', label: 'Sub-subseries', include_in_request: false
        config.add_facet_field 'institution_name_ssim', label: 'Institution', include_in_request: false
        config.add_facet_field 'name_facet_ssim', label: 'Name', include_in_request: false
        config.add_facet_field 'title_info_uniform_ssim', label: 'Title (uniform)', include_in_request: false
        # facet for blacklight-maps catalog#index map view
        # have to use '-2' to get all values
        # because Blacklight::RequestBuilders#solr_facet_params adds '+1' to value
        config.add_facet_field 'subject_geojson_facet_ssim', limit: -2, label: 'Coordinates', show: false

        # solr fields to be displayed in the index (search results) view
        config.add_index_field 'name_facet_ssim', label: 'Creator', separator_options: { two_words_connector: '; ' }
        config.add_index_field 'genre_basic_ssim', label: 'Format', helper_method: :render_format_index
        config.add_index_field 'collection_name_ssim', label: 'Collection', helper_method: :index_collection_link
        config.add_index_field 'date_start_tsim', label: 'Date', helper_method: :index_date_value

        # "fielded" search configuration. Used by pulldown among other places.
        config.add_search_field('all_fields') do |field|
          field.label = 'All Fields'
          field.solr_parameters = { 'spellcheck.dictionary': 'default' }
        end

        config.add_search_field('title') do |field|
          field.solr_parameters = { 
            'spellcheck.dictionary': 'default',
            qf: '${title_qf}',
            pf: '${title_pf}'
          }
          field.solr_adv_parameters = {
            qf: '$title_qf',
            pf: '$title_pf',
          }
        end

        config.add_search_field('subject') do |field|
          field.solr_parameters = {
            'spellcheck.dictionary': 'default',
            qf: '${subject_qf}',
            pf: '${subject_pf}'
          }
          field.solr_adv_parameters = {
            qf: '$subject_qf',
            pf: '$subject_pf',
          }
        end

        config.add_search_field('place') do |field|
          field.solr_parameters = {
            'spellcheck.dictionary': 'default',
            qf: '${place_qf}',
            pf: '${place_pf}'
          }
          field.solr_adv_parameters = {
            qf: '$place_qf',
            pf: '$place_pf',
          }
        end

        config.add_search_field('creator') do |field|
          field.solr_parameters = {
            'spellcheck.dictionary': 'default',
            qf: '${author_qf}',
            pf: '${author_pf}'
          }
          field.solr_adv_parameters = {
            qf: '$author_qf',
            pf: '$author_pf',
          }
        end

        # "sort results by" select (pulldown)
        config.add_sort_field 'score desc, title_info_primary_ssort asc', label: 'relevance'
        config.add_sort_field 'title_info_primary_ssort asc, date_start_dtsi asc', label: 'title'
        config.add_sort_field 'date_start_dtsi asc, title_info_primary_ssort asc', label: 'date (asc)'
        config.add_sort_field 'date_start_dtsi desc, title_info_primary_ssort asc', label: 'date (desc)'

        # add our custom tools
        config.add_show_tools_partial :add_this, partial: 'add_this'
        config.add_show_tools_partial :folder_items, partial: 'folder_item_control'
      end

      # displays the MODS XML record. copied from blacklight-marc 'librarian_view'
      # for some reason won't work if not in the 'included' block
      def metadata_view
        @response, @document = search_service.fetch(params[:id])
        respond_to do |format|
          format.html do
            render layout: false if request.xhr?
          end
          format.js { render layout: false }
        end
      end

      # displays values and pagination links for Format field
      def formats_facet
        @nav_li_active = 'explore'
        @page_title = t('blacklight.formats.page_title', :application_name => t('blacklight.application_name'))
        @facet = blacklight_config.facet_fields['genre_basic_ssim']
        @response = search_service.facet_field_response(@facet.key,
                                                        { 'f.genre_basic_ssim.facet.limit' => -1 })
        @display_facet = @response.aggregations[@facet.key]
        @pagination = facet_paginator(@facet, @display_facet)
        render :facet
      end
    end

    # TODO: refactor how views access files/volumes/etc.
    # returns the child volumes for Book objects (if they exist)
    # needs to be in this module because CommonwealthVlrEngine::Finder methods aren't accessible in helpers/views
    def has_volumes?(document)
      volumes = if document[blacklight_config.show.display_type_field.to_sym] == 'Book'
                  get_volume_objects(document.id)
                else
                  nil
                end
      volumes.presence
    end

    private

    # modify BL config settings for Collections#show and Institutions#show
    def relation_base_blacklight_config
      # don't show collection facet
      blacklight_config.facet_fields['collection_name_ssim'].show = false
      blacklight_config.facet_fields['collection_name_ssim'].if = false
      # collapse remaining facets
      blacklight_config.facet_fields['subject_facet_ssim'].collapse = true
      blacklight_config.facet_fields['subject_geographic_ssim'].collapse = true
      blacklight_config.facet_fields['date_facet_yearly_ssim'].collapse = true
      blacklight_config.facet_fields['genre_basic_ssim'].collapse = true
      blacklight_config.facet_fields['reuse_allowed_ssi'].collapse = true
      # remove item-centric show tools (for admin)
      blacklight_config.show.document_actions.delete(:add_this)
      blacklight_config.show.document_actions.delete(:folder_items)
      blacklight_config.show.document_actions.delete(:custom_email)
      blacklight_config.show.document_actions.delete(:cite)
    end

    # override Blacklight::Catalog#render_sms_action?
    def render_sms_action?
      false
    end

    # TODO: Do we still need this functionality? This method was removed from BL7
    # LOCAL OVERRIDE of Blacklight::SearchHelper
    # needed so that Solr query for prev/next/total in catalog#show view uses correct SearchBuilder class
    # because params added exclusively in SearchBuilder methods don't get saved by current_search_session
    def get_previous_and_next_documents_for_search(index, request_params, extra_controller_params={})
      search_builder_to_use = request_params[:mlt_id] ? CommonwealthMltSearchBuilder.new(self) : search_builder
      p = previous_and_next_document_params(index)
      query = search_builder_to_use.with(request_params).start(p.delete(:start)).rows(p.delete(:rows)).merge(extra_controller_params).merge(p)
      response = repository.search(query)
      document_list = response.documents

      # only get the previous doc if there is one
      prev_doc = document_list.first if index > 0
      next_doc = document_list.last if (index + 1) < response.total
      [response, [prev_doc, next_doc]]
    end

    # if this is 'more like this' search, solr id = params[:mlt_id]
    def mlt_search
      if controller_name == 'catalog' && params[:mlt_id]
        blacklight_config.search_builder_class = CommonwealthMltSearchBuilder
      end
    end

    # TODO: refactor how views access files/volumes/etc.
    def get_object_files
      if controller_name == 'catalog' || controller_name == 'image_viewer'
        @object_files = get_files(params[:id])
      end
    end

    def set_nav_context
      @nav_li_active = 'search' if controller_name == 'catalog'
    end

    # add institutions if configured
    def add_institution_fields
      if t('blacklight.home.browse.institutions.enabled')
        blacklight_config.add_facet_field 'physical_location_ssim', label: 'Institution', limit: 8, sort: 'count', collapse:  false
        blacklight_config.add_index_field 'institution_name_ssim', label: 'Institution', helper_method: :index_institution_link
      end
    end

    # run a separate search for 'more like this' items
    # so we can explicitly set params to exclude unwanted items
    def mlt_results_for_show
      if controller_name == 'catalog' # TODO: possibly redundant, is this ever invoked by another controller?
        #blacklight_config.search_builder_class = CommonwealthMltSearchBuilder
        mlt_search_service = search_service_class.new(config: blacklight_config,
                                                      user_params: { mlt_id: params[:id], rows: 4 },
                                                      search_builder_class: CommonwealthMltSearchBuilder)
        _mlt_response, @mlt_document_list = mlt_search_service.search_results
        # have to reset to CommonwealthSearchBuilder, or prev/next links won't work
        #blacklight_config.search_builder_class = CommonwealthSearchBuilder
      end
    end

    # override so we can inspect for other params, like :mlt_id
    def has_search_parameters?
      params[:mlt_id].present? || super
    end
  end
end
