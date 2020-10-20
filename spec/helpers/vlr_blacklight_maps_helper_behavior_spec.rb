# frozen_string_literal: true

require 'rails_helper'

describe CommonwealthVlrEngine::VlrBlacklightMapsHelperBehavior do
  let(:query_term) { 'Boston' }
  let(:mock_controller) { CatalogController.new }
  let(:blacklight_config) { CatalogController.blacklight_config }
  let(:maps_config) { blacklight_config.view.maps }
  let(:search_service) do
    Blacklight::SearchService.new(config: blacklight_config, user_params: { q: query_term })
  end
  let(:response) { search_service.search_results[0] }
  let(:docs) { response.aggregations[maps_config.geojson_field].items }

  before(:each) do
    mock_controller.request = ActionDispatch::TestRequest.create
    mock_controller.action_name = 'index'
    allow(helper).to receive_messages(controller: mock_controller)
    allow(helper).to receive_messages(blacklight_config: blacklight_config)
    allow(helper).to receive_messages(blacklight_configuration_context: Blacklight::Configuration::Context.new(mock_controller))
    allow(helper).to receive(:search_state).and_return Blacklight::SearchState.new({}, blacklight_config, mock_controller)
    blacklight_config.add_facet_fields_to_solr_request!
  end

  describe '#serialize_geojson' do
    it 'returns geojson of documents' do
      expect(helper.serialize_geojson(docs)).to include('{"type":"FeatureCollection","features":[{"type":"Feature","geometry":{"type":"Point"')
    end
  end

  describe '#link_to_placename_field' do
    it 'handles city, state field values' do
      expect(helper.link_to_placename_field("#{query_term}, MA",
                                            maps_config.placename_field)).to include(
        "search?f%5B#{maps_config.placename_field}%5D%5B%5D=#{query_term}&amp;f%5B#{maps_config.placename_field}%5D%5B%5D=Massachusetts"
      )
    end

    it 'adds the correct route when a catalogpath arg is passed' do
      expect(helper.link_to_placename_field(query_term, maps_config.placename_field,
                                            nil, 'institutions_path')).to include('institutions?')
    end
  end

  describe '#map_facet_values' do
    before(:each) { assign(:response, response) }

    let(:map_facets) { helper.map_facet_values }

    it 'returns the map facet values' do
      expect(map_facets).to be_a_kind_of Array
      expect(map_facets.first).to be_a_kind_of Blacklight::Solr::Response::Facets::FacetItem
      expect(JSON.parse(map_facets.first.value)['type']).to eq 'Feature'
    end
  end

  describe '#render_index_mapview' do
    before(:each) { assign(:response, response) }

    it 'renders the "catalog/index_mapview" partial' do
      expect(helper.render_index_mapview).to include("$('#blacklight-index-map').blacklight_leaflet_map")
    end
  end
end
