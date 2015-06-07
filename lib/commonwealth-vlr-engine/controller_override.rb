module CommonwealthVlrEngine
  module ControllerOverride
    extend ActiveSupport::Concern
    included do

      # Extend Blacklight::Catalog with Hydra behaviors (primarily editing).
      self.send(:include, ::Hydra::Controller::ControllerBehavior)

      if self.respond_to? :search_params_logic
        search_params_logic << :exclude_unwanted_models
      end

      if self.blacklight_config.search_builder_class
        self.blacklight_config.search_builder_class.send(:include,
                                                         CommonwealthVlrEngine::CommonwealthSearchBuilder
        ) unless
            self.blacklight_config.search_builder_class.include?(
                CommonwealthVlrEngine::CommonwealthSearchBuilder
            )
      end

      before_filter :get_object_files, :only => [:show]
      before_filter :set_nav_context, :only => [:index]
      before_filter :mlt_search, :only => [:index]

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
        config.view.maps.maxzoom = 13
        config.view.maps.show_initial_zoom = 9
        config.view.maps.facet_mode = 'geojson'

        # helper that returns thumbnail URLs
        config.index.thumbnail_method = :create_thumb_img_element

        # configuration for search results/index views
        config.index.partials = [:thumbnail, :index_header, :index]
        config.index.document_actions = nil # don't show bookmark control

        # solr field configuration for document/show views
        config.show.title_field = 'title_info_primary_tsi'
        config.show.display_type_field = 'active_fedora_model_suffix_ssi'

        # solr field for flagged/inappropriate content
        config.flagged_field = 'flagged_content_ssi'

        # advanced search facet limits
        config.advanced_search = {
            :qt => 'search',
            :form_solr_parameters => {
                'facet.field' => ['genre_basic_ssim', 'collection_name_ssim'],
                'facet.limit' => -1, # return all facet values
                'facet.sort' => 'index' # sort by byte order of values
            }
        }

        # collection name field
        config.collection_field = 'collection_name_ssim'
        # institution name field
        config.institution_field = 'institution_name_ssim'

        config.default_solr_params = {:qt => 'search', :rows => 20}

        # solr field configuration for search results/index views
        config.index.title_field = 'title_info_primary_tsi'
        config.index.display_type_field = 'active_fedora_model_suffix_ssi'

        # solr fields that will be treated as facets by the blacklight application
        config.add_facet_field 'subject_facet_ssim', :label => 'Topic', :limit => 8, :sort => 'count'
        config.add_facet_field 'subject_geographic_ssim', :label => 'Place', :limit => 8, :sort => 'count'
        config.add_facet_field 'date_facet_ssim', :label => 'Date', :limit => 8, :sort => 'index'
        config.add_facet_field 'genre_basic_ssim', :label => 'Format', :limit => 8, :sort => 'count', :helper_method => :render_format
        config.add_facet_field 'collection_name_ssim', :label => 'Collection', :limit => 8, :sort => 'count'
        # link_to_facet fields (not in facets sidebar of search results)
        config.add_facet_field 'related_item_host_ssim', :label => 'Collection', :include_in_request => false # Collection (local)
        config.add_facet_field 'genre_specific_ssim', :label => 'Genre', :include_in_request => false
        config.add_facet_field 'related_item_series_ssim', :label => 'Series', :include_in_request => false
        config.add_facet_field 'related_item_subseries_ssim', :label => 'Subseries', :include_in_request => false
        config.add_facet_field 'related_item_subsubseries_ssim', :label => 'Sub-subseries', :include_in_request => false
        config.add_facet_field 'institution_name_ssim', :label => 'Institution', :include_in_request => false
        # facet for blacklight-maps catalog#index map view
        # have to use '-2' to get all values
        # because Blacklight::RequestBuilders#solr_facet_params adds '+1' to value
        config.add_facet_field 'subject_geojson_facet_ssim', :limit => -2, :label => 'Coordinates', :show => false

        # solr fields to be displayed in the index (search results) view
        config.add_index_field 'genre_basic_ssim', :label => 'Format'
        config.add_index_field 'collection_name_ssim', :label => 'Collection', :helper_method => :index_collection_link
        config.add_index_field 'date_start_tsim', :label => 'Date', :helper_method => :index_date_value

        # "fielded" search configuration. Used by pulldown among other places.
        config.add_search_field('all_fields') do |field|
          field.label = 'All Fields'
          field.solr_parameters = { :'spellcheck.dictionary' => 'default' }
        end

        config.add_search_field('title') do |field|
          field.solr_parameters = { :'spellcheck.dictionary' => 'default' }
          field.solr_local_parameters = {
              :qf => '$title_qf',
              :pf => '$title_pf'
          }
        end

        config.add_search_field('subject') do |field|
          field.solr_parameters = { :'spellcheck.dictionary' => 'default' }
          field.qt = 'search'
          field.solr_local_parameters = {
              :qf => '$subject_qf',
              :pf => '$subject_pf'
          }
        end

        config.add_search_field('place') do |field|
          field.solr_parameters = { :'spellcheck.dictionary' => 'default' }
          field.solr_local_parameters = {
              :qf => '$place_qf',
              :pf => '$place_pf'
          }
        end

        config.add_search_field('creator') do |field|
          field.solr_parameters = { :'spellcheck.dictionary' => 'default' }
          field.solr_local_parameters = {
              :qf => '$author_qf',
              :pf => '$author_pf'
          }
        end

        # "sort results by" select (pulldown)
        config.add_sort_field 'score desc, title_info_primary_ssort asc', :label => 'relevance'
        config.add_sort_field 'title_info_primary_ssort asc, date_start_dtsi asc', :label => 'title'
        config.add_sort_field 'date_start_dtsi asc, title_info_primary_ssort asc', :label => 'date (asc)'
        config.add_sort_field 'date_start_dtsi desc, title_info_primary_ssort asc', :label => 'date (desc)'

      end

    end

    # displays the MODS XML record. copied from blacklight_marc gem
    def librarian_view
      @response, @document = fetch(params[:id])

      respond_to do |format|
        format.html
        format.js { render :layout => false }
      end
    end

    # displays values and pagination links for Format field
    def formats_facet
      @nav_li_active = 'explore'

      @facet = blacklight_config.facet_fields['genre_basic_ssim']
      @response = get_facet_field_response(@facet.key, params)
      @display_facet = @response.aggregations[@facet.key]

      @pagination = facet_paginator(@facet, @display_facet)

      render :facet
    end

    # if this is 'more like this' search, solr id = params[:mlt_id]
    def mlt_search
      if params[:mlt_id]
        CatalogController.search_params_logic += [:set_solr_id_for_mlt]
      end
    end

    def get_object_files
      @object_files = Bplmodels::Finder.getFiles(params[:id])
    end

    def set_nav_context
      @nav_li_active = 'search'
    end


  end

end