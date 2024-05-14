# frozen_string_literal: true

require 'rails_helper'

# tests for controller actions and configuration added to CatalogController
# via CommonwealthVlrEngine::ControllerOverride
describe CatalogController, :vcr do
  render_views

  let(:item_pid) { 'bpl-dev:df65v790j' }

  describe 'search_builder_class' do
    it 'uses CommonwealthSearchBuilder' do
      expect(described_class.blacklight_config.search_builder_class).to eq(CommonwealthSearchBuilder)
    end
  end

  describe 'GET "metadata_view"' do
    before(:each) { get :metadata_view, params: { id: 'bpl-dev:h702q6403' } }

    it 'responds to the #metadata_view action' do
      expect(response).to be_successful
      expect(assigns(:document)).to_not be_nil
    end

    it 'renders the page' do
      expect(response.body).to include('&lt;mods:title&gt;Beauregard&lt;/mods:title&gt;')
    end
  end

  describe 'GET "formats_facet"' do
    before(:each) { get :formats_facet }

    it 'responds to the #formats_facet action' do
      expect(response).to be_successful
      expect(assigns(:display_facet)).to_not be_nil
    end

    it 'renders the page' do
      expect(response.body).to have_css('.facet-extended-list')
    end
  end

  describe 'mlt_search' do
    it 'modifies the config to use the correct search builder class' do
      get :index, params: { mlt_id: item_pid }
      expect(controller.blacklight_config.search_builder_class).to eq(CommonwealthMltSearchBuilder)
    end
  end

  describe 'object_files' do
    it 'retrieves the files for the item' do
      get :show, params: { id: item_pid }
      expect(assigns(:object_files)).to_not be_nil
    end
  end

  describe 'mlt_results_for_show' do
    it 'retrieves the mlt results for the item' do
      get :show, params: { id: item_pid }
      expect(assigns(:mlt_document_list)).to_not be_falsey
    end
  end

  describe 'add_institution_fields' do
    it 'adds the institution-related facet fields to the config' do
      get :index
      expect(controller.blacklight_config.facet_fields['physical_location_ssim']).to_not be_nil
    end
  end

  describe 'set_nav_context' do
    it 'sets the nav context' do
      get :index
      expect(assigns(:nav_li_active)).to eq('search')
    end
  end
end
