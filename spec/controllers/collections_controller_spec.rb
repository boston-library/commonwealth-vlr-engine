# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CollectionsController, :vcr do
  render_views

  let(:blacklight_config) { CatalogController.blacklight_config }
  let(:collection_pid) { 'bpl-dev:h702q636h' }

  describe 'GET "index"' do
    it 'should show the collections page' do
      get :index
      expect(response).to be_successful
      expect(assigns(:response)).not_to be_nil
      expect(response.body).to have_selector('.blacklight-collection')
    end
  end

  describe 'GET "show"' do
    before(:each) do
      get :show, params: { id: collection_pid }
    end

    it 'should show the collection page' do
      expect(response).to be_successful
      expect(assigns(:document)).not_to be_nil
      expect(response.body).to have_selector('.blacklight-collection')
    end

    it 'should set @exemplary_document' do
      expect(assigns(:exemplary_document)).to_not be_falsey
    end

    it 'should show the series list' do
      expect(response.body).to have_selector('#series')
      expect(assigns(:response)).not_to be_nil
    end

    it 'should show the featured items' do
      expect(response.body).to have_selector('.featured_items')
      expect(assigns(:featured_items)).not_to be_nil
    end
  end

  describe 'GET "range_limit"' do
    it 'redirects to range_limit_catalog_path' do
      get :range_limit
      expect(response).to be_redirect
    end
  end

  describe 'private methods and before_actions' do
    let(:document) { SolrDocument.find(collection_pid) }
    let(:mock_controller) { described_class.new }

    before(:each) do
      mock_controller.params = {}
      mock_controller.request = ActionDispatch::TestRequest.create
    end

    describe 'collections_index_config' do
      it 'sets the correct configuration' do
        mock_controller.send(:collections_index_config)
        expect(mock_controller.blacklight_config.search_builder_class).to eq(CommonwealthVlrEngine::CollectionsSearchBuilder)
        expect(mock_controller.blacklight_config.index.search_header_component).to eq(CommonwealthVlrEngine::CollectionsSearchHeaderComponent)
        expect(mock_controller.blacklight_config.view.masonry.document_component).to be_falsey
      end
    end

    describe 'collections_show_config' do
      it 'sets the correct configuration' do
        mock_controller.send(:collections_show_config)
        expect(mock_controller.blacklight_config.show.metadata_component).to be_falsey
        expect(mock_controller.blacklight_config.search_fields[:subject]).to be_falsey
        expect(mock_controller.blacklight_config.advanced_search.enabled).to be_falsey
        expect(mock_controller.blacklight_config.facet_fields['related_item_series_ssi'].include_in_request).to eq(true)
      end
    end

    describe 'set_collection_facet_params' do
      it 'sets the correct facet params' do
        expect(mock_controller.send(:set_collection_facet_params,
                                    'Carte de Visite Collection',
                                    document)[blacklight_config.collection_field][0]).to eq('Carte de Visite Collection')
      end
    end

    # method is DEPRECATED, but possibly needed in the future
    # describe 'collapse_institution_facet' do
    #   it 'should collapse the institution facet' do
    #     mock_controller.send(:collapse_institution_facet)
    #     expect(mock_controller.blacklight_config.facet_fields['physical_location_ssim'].collapse).to eq(true)
    #   end
    # end

    # method is DEPRECATED, but possibly needed in the future
    # TODO: spec for case where request.query_parameters exist
    # can't figure out how to set these in a spec
    # describe 'collections_limit_for_facets' do
    #   it 'sets the correct search builder class' do
    #     mock_controller.send(:collections_limit_for_facets)
    #     expect(mock_controller.blacklight_config.search_builder_class).to eq(CommonwealthVlrEngine::CollectionsSearchBuilder)
    #   end
    # end

    # method is DEPRECATED, but possibly needed in the future
    # method from CommonwealthVlrEngine::ControllerOverride
    # describe 'relation_base_blacklight_config' do
    #   before(:each) { mock_controller.send(:relation_base_blacklight_config) }
    #
    #   it 'sets the collection_name_ssim facet :show property to false' do
    #     expect(mock_controller.blacklight_config.facet_fields['collection_name_ssim'].show).not_to be_truthy
    #   end
    #
    #   it 'sets the collapse property to true for all displayed facets' do
    #     expect(mock_controller.blacklight_config.facet_fields['subject_facet_ssim'].collapse).to be_truthy
    #   end
    #
    #   it 'should remove the citation tool from the show tools' do
    #     expect(mock_controller.blacklight_config.show.document_actions[:citation][:partial]).to be_falsey
    #   end
    # end
  end
end
