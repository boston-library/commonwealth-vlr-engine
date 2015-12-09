require 'spec_helper'

describe OcrSearchController do

  describe "GET 'index'" do

    describe 'with no ocr_q search params' do

      it 'should render the page' do
        get :index, :id => 'bpl-dev:7s75dn48d'
        expect(response).to be_success
        expect(assigns(:document_list)).to be_empty
      end

    end

    describe 'with ocr_q search params' do

      before { get :index, :id => 'bpl-dev:7s75dn48d', :ocr_q => 'instruction' }

      it 'should render the page' do
        expect(response).to be_success
        expect(assigns(:document_list).length).to eq(2)
      end

      it 'should include highlighting in the Solr response' do
        expect(assigns(:response)['highlighting']).not_to be_empty
      end

    end

  end

  describe 'private methods' do

    # for testing private methods
    class OcrSearchControllerTestClass < OcrSearchController
    end

    before(:each) do
      @mock_controller = OcrSearchControllerTestClass.new
    end

    describe 'modify_config_for_ocr' do

      let(:blacklight_config) { @mock_controller.blacklight_config }

      before { @mock_controller.send(:modify_config_for_ocr) }

      it 'should set add_facet_fields_to_solr_request to false' do
        expect(blacklight_config.add_facet_fields_to_solr_request).to eq(false)
      end

      let(:ocr_field) { blacklight_config.index_fields[blacklight_config.ocr_search_field] }

      it 'should add the ocr_search_field to the index_fields config' do
        expect(ocr_field.class).to eq(Blacklight::Configuration::IndexField)
        expect(ocr_field.highlight).to eq(true)
      end

    end

    describe 'start_new_search_session?' do
      it 'should return false' do
        expect(@mock_controller.send(:start_new_search_session?)).to eq(false)
      end
    end

  end

end