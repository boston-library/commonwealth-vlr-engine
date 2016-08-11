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

end