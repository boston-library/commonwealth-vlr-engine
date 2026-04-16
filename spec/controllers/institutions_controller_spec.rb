# frozen_string_literal: true

require 'rails_helper'

RSpec.describe InstitutionsController, :vcr do
  render_views

  describe "GET 'index'" do
    it 'shows the institutions page' do
      get :index
      expect(response).to be_successful
      expect(response.body).to have_selector('.blacklight-institution')
      expect(assigns(:response)).not_to be_nil
    end

    # TODO: re-enable once Blacklight::Maps has been integrated
    # describe 'map view' do
    #   it 'shows the map on institutions page' do
    #     get :index, params: { view: 'maps' }
    #     expect(response.body).to have_selector('#institutions-index-map')
    #   end
    # end
  end

  describe "GET 'show'" do
    let(:institution_id) { 'bpl-dev:abcd12345' }
    before(:each) do
      get :show, params: { id: institution_id }
    end

    it 'shows the institution page' do
      expect(response).to be_successful
      expect(response.body).to have_selector('div.blacklight-institution')
      expect(assigns(:document)).not_to be_nil
    end

    it 'should set @exemplary_document' do
      expect(assigns(:exemplary_document)).to_not be_falsey
    end

    it 'shows a list of collections' do
      expect(response.body).to have_selector('#institution_collections')
      expect(assigns(:collex_documents)).not_to be_nil
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
    let(:mock_controller) { described_class.new }

    describe 'institutions_index_config' do
      it 'sets the correct configuration' do
        mock_controller.send(:institutions_index_config)
        expect(mock_controller.blacklight_config.search_builder_class).to eq(CommonwealthVlrEngine::InstitutionsSearchBuilder)
        expect(mock_controller.blacklight_config.show.route).to eq({ controller: 'institutions' })
        expect(mock_controller.blacklight_config.view.masonry.document_component).to be_falsey
      end
    end

    describe 'institutions_show_config' do
      it 'sets the correct configuration' do
        mock_controller.send(:institutions_show_config)
        expect(mock_controller.blacklight_config.show.document_component).to be_falsey
        expect(mock_controller.blacklight_config.show.metadata_component).to be_falsey
        expect(mock_controller.blacklight_config.search_fields[:subject]).to be_falsey
        expect(mock_controller.blacklight_config.advanced_search.enabled).to be_falsey
      end
    end
  end
end
