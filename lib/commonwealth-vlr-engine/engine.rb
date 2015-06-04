require 'blacklight'

module CommonwealthVlrEngine
  class Engine < Rails::Engine

    # Set some default configurations
    #Blacklight::Configuration.default_values[:view].maps.geojson_field = "geojson"
=begin
    #set default per-page
    Blacklight::Configuration.default_values[:default_per_page] = 20

    Blacklight::Configuration.default_values[:index].partials = [:thumbnail, :index_header, :index]
    Blacklight::Configuration.default_values[:index].document_actions = nil # don't show bookmark control

    # solr field configuration for document/show views
    Blacklight::Configuration.default_values[:show].title_field = 'title_info_primary_tsi'
    Blacklight::Configuration.default_values[:show].display_type_field = 'active_fedora_model_suffix_ssi'

    # solr field for flagged/inappropriate content
    Blacklight::Configuration.default_values[:flagged_field] = 'flagged_content_ssi'

    # helper that returns thumbnail URLs
    Blacklight::Configuration.default_values[:index].thumbnail_method = :create_thumb_img_element

    #blacklight-gallery stuff
    Blacklight::Configuration.default_values[:view].gallery.default = true
    Blacklight::Configuration.default_values[:view].gallery.partials = [:index_header]
    Blacklight::Configuration.default_values[:view].gallery.icon_class = 'glyphicon-th-large'
    Blacklight::Configuration.default_values[:view].masonry.partials = [:index_header]
    Blacklight::Configuration.default_values[:view].slideshow.partials = [:index]


    # advanced search facet limits
    Blacklight::Configuration.default_values[:advanced_search] = {
        :qt => 'search',
        :form_solr_parameters => {
            'facet.field' => ['genre_basic_ssim', 'physical_location_ssim'],
            'facet.limit' => -1, # return all facet values
            'facet.sort' => 'index' # sort by byte order of values
        }
    }

    # collection name field
    Blacklight::Configuration.default_values[:collection_field] = 'collection_name_ssim'
    # institution name field
    Blacklight::Configuration.default_values[:institution_field] = 'institution_name_ssim'

    # blacklight-maps stuff
    Blacklight::Configuration.default_values[:view].maps.geojson_field = 'subject_geojson_facet_ssim'
    Blacklight::Configuration.default_values[:view].maps.coordinates_field = 'subject_coordinates_geospatial'
    Blacklight::Configuration.default_values[:view].maps.placename_field = 'subject_geographic_ssim'
    Blacklight::Configuration.default_values[:view].maps.maxzoom = 13
    Blacklight::Configuration.default_values[:view].maps.show_initial_zoom = 9
    Blacklight::Configuration.default_values[:view].maps.facet_mode = 'geojson'
=end


    # Add our helpers
    #initializer 'commonwealth-vlr-engine.helpers' do |app|
    #  ActionView::Base.send :include, BlacklightMapsHelper
    #end

    config.to_prepare do
      CommonwealthVlrEngine.inject!
    end

    # This makes our rake tasks visible.
    rake_tasks do
      Dir.chdir(File.expand_path(File.join(File.dirname(__FILE__), '..', '..'))) do
        Dir.glob(File.join('railties', '*.rake')).each do |railtie|
          load railtie
        end
      end
    end
  end
end
