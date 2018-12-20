# rake tasks for Commonwealth-public-interface

namespace :vlr_engine do

  desc 'generate the static geojson file for catalog#map view'
  task :create_geojson => :environment do

    include BlacklightMapsHelper

    def blacklight_config
      CatalogController.blacklight_config
    end

    class BlacklightGeojsonTestClass < CatalogController
      include Blacklight::SearchHelper
    end

    @controller = BlacklightGeojsonTestClass.new
    @controller.request = ActionDispatch::TestRequest.new

    (@response, @document_list) = @controller.search_results({})

    geojson_features = serialize_geojson(map_facet_values, 'index')
    if geojson_features
      File.open("#{Rails.root.to_s}/#{GEOJSON_STATIC_FILE['filepath']}", 'w') {|f| f.write(geojson_features) }
      puts 'The GeoJSON file has successfully been created'
    else
      puts 'ERROR: The GeoJSON file was not created!'
    end

  end
end