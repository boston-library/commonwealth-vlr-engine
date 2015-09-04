require 'spec_helper'

describe ImageViewerController do

  render_views

  include CommonwealthVlrEngine::Finder

  before(:each) do
    @item_id = 'bpl-dev:h702q6403'
    @first_image_pid = 'bpl-dev:h702q641c'
    @second_image_pid = 'bpl-dev:h702q642n'
  end

  describe "GET 'show'" do
    it 'should render the partial using ajax with the new image' do
      xhr :get, :show, :id => @item_id, :view => @second_image_pid
      expect(response).to be_success
      # not great, but OK for now
      expect(response.body).to match /#{@second_image_pid}/
    end
  end

  describe 'get #book_viewer' do
    it 'should render the book viewer' do
      get :book_viewer, :id => @item_id
      expect(response).to be_success
      expect(response.body).to have_selector('#viewer')
    end
  end

  describe "private methods" do

    # for testing private methods
    class ImageViewerControllerTestClass < ImageViewerController
    end

    before(:each) do
      @mock_controller = ImageViewerControllerTestClass.new
    end

    describe "get_page_sequence" do
      it "should return the correct page sequence" do
        expect(@mock_controller.send(:get_page_sequence,@item_id,@first_image_pid)).to eq({current: @first_image_pid, index: 1, total: 2, prev: nil, next: @second_image_pid})
      end
    end

  end

end