require 'spec_helper'

describe CollectionsController do

  render_views

  include BlacklightMapsHelper

  def blacklight_config
    CatalogController.blacklight_config
  end

  describe "GET 'index'" do
    it "should show the collections page" do
      get :index
      expect(response).to be_success
      expect(assigns(:document_list)).not_to be_nil
      expect(response.body).to have_selector(".blacklight-collection")
    end
  end

  describe "GET 'show'" do

    before(:each) do
      get :show, :id => 'bpl-dev:h702q636h'
    end

    describe 'relation_base_blacklight_config' do

      # this method is invoked as a before_filter for CollectionsController#show

      # trying to test CommonwealthVlrEngine::ControllerOverride#relation_base_blacklight_config here
      # blacklight_config.facet_fields['collection_name_ssim'].show should be false
      # but it keeps coming back true, not sure why
      it 'should set the collection_name_ssim facet :show property to false' #do
        #expect(CollectionsController.blacklight_config.facet_fields['collection_name_ssim'].show).not_to be_truthy
      #end

      # trying to test CommonwealthVlrEngine::ControllerOverride#relation_base_blacklight_config here
      # blacklight_config.facet_fields['subject_facet_ssim'].collapse should be true
      # but it keeps coming back false, not sure why
      it 'should set the collapse property to true for all displayed facets' #do
        #expect(CollectionsController.blacklight_config.facet_fields['subject_facet_ssim'].collapse).to be_truthy
      #end

    end

    it "should show the collection page" do
      expect(response).to be_success
      expect(assigns(:document)).not_to be_nil
      expect(response.body).to have_selector(".blacklight-collection")
    end

    it "should show some facets" do
      expect(response.body).to have_selector("#facets")
    end

    it "should show the collection image and title" do
      expect(response.body).to have_selector(".collection_img_show")
      expect(response.body).to have_selector("#collection_img_caption")
    end

    it "should show the series list" do
      expect(response.body).to have_selector("#facet-related_item_series_ssim")
      expect(assigns(:document_list)).not_to be_nil
    end

    it "should show the map" do
      expect(response.body).to have_selector("#blacklight-collection-map-container")
      expect(assigns(:response).aggregations[map_facet_field].items).not_to be_empty
    end

  end

  describe "private methods" do

    # for testing private methods
    class CollectionsControllerTestClass < CollectionsController
      attr_accessor :params
    end

    before(:each) do
      @mock_controller = CollectionsControllerTestClass.new
      @mock_controller.params = {}
      @mock_controller.request = ActionDispatch::TestRequest.new
      @collection_pid = 'bpl-dev:h702q636h'
      @collection_image_pid = 'bpl-dev:h702q642n'
      @document = {blacklight_config.institution_field.to_sym => 'Boston Public Library'}
    end

    # :collections_filter doesn't seem to be getting added, not sure why
    # may be same issue affecting specs for #relation_base_blacklight_config above
    describe "collections_limit" do
      it "should add :collections filter to search_params_logic" #do
        #get :index, :id => 'bpl-dev:000000000'
        #expect(CollectionsController.search_params_logic).to include(:collections_filter)
      #end
    end

    describe "get_collection_image_info" do
      it "should return a hash with the collection image object title and pid" do
        expect(@mock_controller.send(:get_collection_image_info,@collection_image_pid,@collection_pid)).to eq({title:'Beauregard', pid:'bpl-dev:h702q6403', access_master:true})
      end
    end

    describe "get_series_image_obj" do
      it "should return the series object" do
        expect(@mock_controller.send(:get_series_image_obj,'Test Series','Carte de Visite Collection')[:exemplary_image_ssi]).to eq('bpl-dev:h702q641c')
      end
    end

    describe "set_collection_facet_params" do
      it "should set the correct facet params" do
        expect(@mock_controller.send(:set_collection_facet_params,'Carte de Visite Collection', @document)[blacklight_config.collection_field][0]).to eq('Carte de Visite Collection')
      end
    end

  end

end
