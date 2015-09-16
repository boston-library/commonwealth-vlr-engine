require 'spec_helper'

# tests for controller actions added to CatalogController via CommonwealthVlrEngine::ControllerOverride
describe CatalogController do

  render_views

  #include CommonwealthVlrEngine::Finder

  describe 'GET "metadata_view"' do

    before { get :metadata_view, :id => 'bpl-dev:h702q6403'}

    it 'should respond to the #metadata_view action' do
      expect(response).to be_success
      expect(assigns(:document)).to_not be_nil
    end

    it 'should render the page' do
      expect(response.body).to include('&lt;mods:title&gt;Beauregard&lt;/mods:title&gt;')
    end

  end

  describe 'GET "formats_facet"' do

    before { get :formats_facet }

    it 'should respond to the #formats_facet action' do
      expect(response).to be_success
      expect(assigns(:display_facet)).to_not be_nil
    end

    it 'should render the page' do
      expect(response.body).to have_css('.facet_extended_list')
    end

  end

  describe 'mlt_search' do

    it 'should include :set_solr_id_for_mlt in search_params_logic' do
      get :index, :mlt_id => 'bpl-dev:df65v790j'
      expect(CatalogController.search_params_logic).to include(:set_solr_id_for_mlt)
    end

  end

  describe 'get_object_files' do

    it 'should retrieve the files for the item' do
      get :show, :id => 'bpl-dev:df65v790j'
      expect(assigns(:object_files)).to_not be_nil
    end

  end

  describe 'set_nav_context' do

    it 'should set the nav context' do
      get :index
      expect(assigns(:nav_li_active)).to eq('search')
    end

  end

end