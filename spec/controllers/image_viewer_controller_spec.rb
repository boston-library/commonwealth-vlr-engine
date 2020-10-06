require 'rails_helper'

describe ImageViewerController do
  render_views

  include CommonwealthVlrEngine::Finder

  let(:item_pid) { 'bpl-dev:h702q6403' }
  let(:first_image_pid) { 'bpl-dev:h702q641c' }
  let(:second_image_pid) { 'bpl-dev:h702q642n' }

  describe "GET 'show'" do
    it 'renders the partial using ajax with the new image' do
      get :show, xhr: true, params: { id: item_pid, view: second_image_pid }
      expect(response).to be_successful
      # not great, but OK for now
      expect(response.body).to match /#{second_image_pid}/
    end
  end

  describe 'get #book_viewer' do
    it 'renders the book viewer' do
      get :book_viewer, params: { id: item_pid }
      expect(response).to be_successful
      expect(response.body).to have_selector('#uv')
    end
  end
end
