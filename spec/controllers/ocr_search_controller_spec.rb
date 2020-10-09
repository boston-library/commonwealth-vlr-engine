require 'rails_helper'

describe OcrSearchController do
  render_views

  describe "GET 'index'" do
    describe 'with no ocr_q search params' do
      it 'renders the page' do
        get :index, params: { id: 'bpl-dev:7s75dn48d' }
        expect(response).to be_successful
        expect(assigns(:document_list)).to be_empty
      end
    end

    describe 'with ocr_q search params' do
      describe 'with blank ocr_q search params' do
        before { get :index, params: { id: 'bpl-dev:7s75dn48d', ocr_q: '' }}

        it 'renders the page' do
          expect(response).to be_successful
          expect(assigns(:document_list)).to be_empty
        end
      end

      describe 'with valid ocr_q search params' do
        before { get :index, params: { id: 'bpl-dev:7s75dn48d', ocr_q: 'instruction' }}

        it 'renders the page' do
          expect(response).to be_successful
          expect(assigns(:document_list).length).to eq(2)
        end

        it 'should include highlighting in the Solr response' do
          expect(assigns(:response)['highlighting']).not_to be_empty
        end
      end
    end
  end

  describe 'private methods' do
    let(:mock_controller) { OcrSearchController.new }

    describe 'modify_config_for_ocr' do
      let(:blacklight_config) { mock_controller.blacklight_config }
      let(:ocr_field) { blacklight_config.index_fields[blacklight_config.ocr_search_field] }

      before { mock_controller.send(:modify_config_for_ocr) }

      it 'sets add_facet_fields_to_solr_request to false' do
        expect(blacklight_config.add_facet_fields_to_solr_request).to eq(false)
      end

      it 'adds the ocr_search_field to the index_fields config' do
        expect(ocr_field.class).to eq(Blacklight::Configuration::IndexField)
        expect(ocr_field.highlight).to eq(true)
      end
    end

    describe 'start_new_search_session?' do
      it 'returns false' do
        expect(mock_controller.send(:start_new_search_session?)).to eq(false)
      end
    end
  end
end
