# frozen_string_literal: true

require 'rails_helper'

describe InstitutionsController do
  render_views

  describe "GET 'index'" do
    it 'shows the institutions page' do
      get :index
      expect(response).to be_successful
      expect(response.body).to have_selector('.blacklight-institution')
      expect(assigns(:document_list)).not_to be_nil
    end

    describe 'remove_unwanted_views' do
      it 'does not show the gallery, masonry, or slideshow views' do
        get :index
        expect(response.body).to_not have_selector('.view-type-gallery')
        expect(response.body).to_not have_selector('.view-type-masonry')
        expect(response.body).to_not have_selector('.view-type-slideshow')
      end
    end

    describe 'map view' do
      it 'shows the map on institutions page' do
        get :index, params: { view: 'maps' }
        expect(response.body).to have_selector('#institutions-index-map')
      end
    end
  end

  describe "GET 'show'" do
    let(:institution_id) { 'bpl-dev:abcd12345' }

    it 'shows the institution page' do
      get :show, params: { id: institution_id }
      expect(response).to be_successful
      expect(response.body).to have_selector('div.blacklight-institution')
      expect(assigns(:document)).not_to be_nil
    end

    it 'shows some facets' do
      get :show, params: { id: institution_id }
      expect(response.body).to have_selector('#facets')
    end

    it 'shows a list of collections' do
      get :show, params: { id: institution_id }
      expect(response.body).to have_selector('#institution_collections')
      expect(assigns(:document_list)).not_to be_nil
    end
  end

  describe 'GET "range_limit"' do
    it 'redirects to range_limit_catalog_path' do
      get :range_limit
      expect(response).to be_redirect
    end
  end

  describe 'private methods and before_actions' do
    describe 'institutions_index_config' do
      it 'sets the appropriate blacklight_config properties' do
        get :index
        expect(controller.blacklight_config.search_builder_class).to eq(CommonwealthInstitutionsSearchBuilder)
        expect(controller.blacklight_config.view.to_s).not_to include('gallery')
      end
    end
  end
end
