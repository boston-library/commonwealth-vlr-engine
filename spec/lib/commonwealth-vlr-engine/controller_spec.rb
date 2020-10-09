require 'rails_helper'

describe CommonwealthVlrEngine::Controller do
  class ControllerTestClass < ActionController::Base
    include CommonwealthVlrEngine::Controller
  end

  let(:mock_controller) { CatalogController.new }

  describe 'create_img_sequence' do
    let(:current_img_pid) { 'bpl-dev:h702q642n' }
    let(:image_files) { ['bpl-dev:h702q641c', current_img_pid] }
    let(:image_sequence) { mock_controller.create_img_sequence(image_files, current_img_pid) }

    it 'sets the index to the correct value' do
      expect(image_sequence[:index]).to eq(2)
    end

    it 'sets the previous image to the correct value' do
      expect(image_sequence[:prev]).to eq(image_files[0])
    end

    it 'sets the next image to the correct value' do
      expect(image_sequence[:next]).to eq(nil)
    end
  end

  describe '#not_found' do
    it 'raises a not found error' do
      expect do
        mock_controller.not_found
      end.to raise_error(ActionController::RoutingError)
    end
  end

  describe 'render_bookmarks_control?' do
    it 'returns false' do
      expect(mock_controller.render_bookmarks_control?).to be_falsey
    end
  end

  describe 'search_action_path' do
    before(:each) do
      mock_controller.params = {}
      mock_controller.request = ActionDispatch::TestRequest.create
    end

    describe "institutions#index" do
      before do
        mock_controller.params[:action] = 'index'
        mock_controller.params[:controller] = 'institutions'
      end

      it "returns institutions_url" do
        expect(mock_controller.search_action_path).to include('/institutions')
      end
    end

    describe "collections" do
      before { mock_controller.params[:controller] = 'collections' }

      describe "#index" do
        before { mock_controller.params[:action] = 'index' }

        it "returns collections_url" do
          expect(mock_controller.search_action_path).to include('/collections')
        end
      end

      describe "#facet" do
        before { mock_controller.params[:action] = 'facet' }

        it "returns collections_url" do
          expect(mock_controller.search_action_path).to include('/collections')
        end
      end
    end
  end

  describe 'determine_layout' do
    it 'returns the correct layout' do
      expect(mock_controller.send(:determine_layout)).to eq('commonwealth-vlr-engine')
    end
  end
end
