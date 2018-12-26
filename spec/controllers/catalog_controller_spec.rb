require 'spec_helper'

# tests for controller actions and configuration added to CatalogController via CommonwealthVlrEngine::ControllerOverride
describe CatalogController do

  render_views

  #include CommonwealthVlrEngine::Finder

  describe 'search_builder_class' do

    it 'should use CommonwealthSearchBuilder' do
      expect(CatalogController.blacklight_config.search_builder_class).to eq(CommonwealthSearchBuilder)
    end

  end

  describe 'GET "metadata_view"' do

    before { get :metadata_view, params: {id: 'bpl-dev:h702q6403'}}

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

    it 'should modify the config to use the correct search builder class' do
      get :index, params: {mlt_id: 'bpl-dev:df65v790j'}
      expect(controller.blacklight_config.search_builder_class).to eq(CommonwealthMltSearchBuilder)
    end

  end

  describe 'get_object_files' do

    it 'should retrieve the files for the item' do
      get :show, params: {id: 'bpl-dev:df65v790j'}
      expect(assigns(:object_files)).to_not be_nil
    end

  end

  describe 'add_institution_fields' do

    it 'should add the institution-related facet fields to the config' do
      get :index
      expect(controller.blacklight_config.facet_fields['physical_location_ssim']).to_not be_nil
    end

  end

  describe 'set_nav_context' do

    it 'should set the nav context' do
      get :index
      awesome_print response.body
      expect(assigns(:nav_li_active)).to eq('search')
    end

  end

end
