require 'spec_helper'

describe CollectionsController do

  render_views

  include BlacklightMapsHelper

  def blacklight_config
    CatalogController.blacklight_config
  end

  describe 'GET "index"' do
    it 'should show the collections page' do
      get :index
      expect(response).to be_success
      expect(assigns(:document_list)).not_to be_nil
      expect(response.body).to have_selector('.blacklight-collection')
    end
  end

  describe 'GET "show"' do

    before(:each) do
      get :show, params: {id: 'bpl-dev:h702q636h'}
    end

    it 'should show the collection page' do
      expect(response).to be_success
      expect(assigns(:document)).not_to be_nil
      expect(response.body).to have_selector('.blacklight-collection')
    end

    it 'should show some facets' do
      expect(response.body).to have_selector('#facets')
    end

    it 'should show the collection image and title' do
      expect(response.body).to have_selector('.collection_img_show')
      expect(response.body).to have_selector('#collection_img_caption')
    end

    it 'should show the series list' do
      expect(response.body).to have_selector('#facet-related_item_series_ssim')
      expect(assigns(:document_list)).not_to be_nil
    end

    it 'should show the map' do
      expect(response.body).to have_selector('#blacklight-collection-map-container')
      expect(assigns(:response).aggregations[map_facet_field].items).not_to be_empty
    end

  end

  describe 'GET "range_limit"' do
    it 'should redirect to range_limit_catalog_path' do
      get :range_limit
      expect(response).to be_redirect
    end
  end

  describe 'private methods and before_actions' do

    # for testing private methods
    class CollectionsControllerTestClass < CollectionsController
      attr_accessor :params
    end

    before(:each) do
      @mock_controller = CollectionsControllerTestClass.new
      @mock_controller.params = {}
      @mock_controller.request = ActionDispatch::TestRequest.new
      @mock_controller.send(:add_institution_fields)
      @collection_pid = 'bpl-dev:h702q636h'
      @collection_image_pid = 'bpl-dev:h702q642n'
      @document = {blacklight_config.institution_field.to_sym => 'Boston Public Library'}
    end

    describe 'add_series_facet' do
      it 'should add the series facet to the Solr request' do
        @mock_controller.send(:add_series_facet)
        expect(@mock_controller.blacklight_config.facet_fields['related_item_series_ssim'].include_in_request).to eq(true)
      end
    end

    describe 'collapse_institution_facet' do
      it 'should collapse the institution facet' do
        @mock_controller.send(:collapse_institution_facet)
        expect(@mock_controller.blacklight_config.facet_fields['physical_location_ssim'].collapse).to eq(true)
      end
    end

    describe 'collections_limit' do
      it 'should set the correct search builder class' do
        @mock_controller.send(:collections_limit)
        expect(@mock_controller.blacklight_config.search_builder_class).to eq(CommonwealthCollectionsSearchBuilder)
      end
    end

    # TODO: spec for case where request.query_parameters exist
    # can't figure out how to set these in a spec
    describe 'collections_limit_for_facets' do
      it 'should set the correct search builder class' do
        @mock_controller.send(:collections_limit_for_facets)
        expect(@mock_controller.blacklight_config.search_builder_class).to eq(CommonwealthCollectionsSearchBuilder)
      end
    end

    describe 'get_collection_image_info' do
      it 'should return a hash with the collection image object title and pid' do
        expect(@mock_controller.send(:get_collection_image_info,@collection_image_pid,@collection_pid)).to eq({title:'Beauregard', pid:'bpl-dev:h702q6403', access_master:true})
      end
    end

    describe 'get_series_image_obj' do
      it 'should return the series object' do
        expect(@mock_controller.send(:get_series_image_obj,'Test Series','Carte de Visite Collection')[:exemplary_image_ssi]).to eq('bpl-dev:h702q641c')
      end
    end

    describe 'set_collection_facet_params' do
      it 'should set the correct facet params' do
        expect(@mock_controller.send(:set_collection_facet_params,'Carte de Visite Collection', @document)[blacklight_config.collection_field][0]).to eq('Carte de Visite Collection')
      end
    end

    describe 'relation_base_blacklight_config' do

      before { @mock_controller.send(:relation_base_blacklight_config) }

      it 'should set the collection_name_ssim facet :show property to false' do
        expect(@mock_controller.blacklight_config.facet_fields['collection_name_ssim'].show).not_to be_truthy
      end

      it 'should set the collapse property to true for all displayed facets' do
        expect(@mock_controller.blacklight_config.facet_fields['subject_facet_ssim'].collapse).to be_truthy
      end

      it 'should remove the citation tool from the show tools' do
        expect(@mock_controller.blacklight_config.show.document_actions[:cite]).to be_empty
      end

    end

  end

end
