# frozen_string_literal: true

# rake tasks for Commonwealth-public-interface
namespace :vlr_engine do
  # desc 'generate the static geojson file for catalog#map view'
  # task :create_geojson => :environment do
  #   #include BlacklightMapsHelper
  #
  #   def blacklight_config
  #     CatalogController.blacklight_config
  #   end
  #
  #   @controller = CatalogController.new
  #   @controller.request = ActionDispatch::TestRequest.create
  #   geojson_search_service = Blacklight::SearchService.new(config: blacklight_config)
  #   @response = geojson_search_service.search_results
  #
  #   geojson_features = serialize_geojson(map_facet_values, 'index')
  #   if geojson_features
  #     File.open("#{Rails.root}/#{GEOJSON_STATIC_FILE['filepath']}", 'w') do |f|
  #       f.write(geojson_features)
  #     end
  #     puts 'The GeoJSON file has successfully been created'
  #   else
  #     puts 'ERROR: The GeoJSON file was not created!'
  #   end
  # end
end
