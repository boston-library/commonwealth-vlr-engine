# frozen_string_literal: true

require 'rails_helper'

describe DownloadsController, :vcr do
  render_views

  let(:item_id) { 'bpl-dev:h702q6403' }
  let(:filestream_id) { 'image_access_800' }
  let(:first_image_pid) { 'bpl-dev:h702q641c' }

  describe "GET 'show'" do
    describe 'file object (single item download)' do
      it 'should be successful and set the right instance variables' do
        get :show, xhr: true, params: { id: first_image_pid, filestream_id: filestream_id }
        expect(response).to be_successful
        expect(assigns(:parent_document).id).to eq(item_id)
        expect(assigns(:object_profile).class).to eq(Hash)
      end
    end

    describe 'top-level object (ZIP download)' do
      it 'should be successful and set the right instance variables' do
        get :show,  xhr: true, params: { id: item_id, filestream_id: filestream_id }
        expect(response).to be_successful
        expect(assigns(:parent_document)).to eq(assigns(:document))
        expect(assigns(:object_profile)).to be_nil
      end
    end
  end

  describe "GET 'trigger_download'" do
    let(:file_name) { item_id.tr(':', '_') }

    describe 'file object (single item download)' do
      it 'should be successful and set the right headers' do
        get :trigger_download, params: { id: first_image_pid, filestream_id: filestream_id }
        expect(response).to be_successful
        expect(response.headers['Content-Type']).to eq('image/jpeg')
        expect(response.headers['Content-Disposition']).to include(
          "attachment; filename=\"#{file_name}_#{filestream_id}.jpg\""
        )
      end
    end

    describe 'top-level object (ZIP download)' do
      it 'should be successful and set the right instance variables' do
        get :trigger_download, params: { id: item_id, filestream_id: filestream_id }
        expect(response).to be_successful
        expect(response.headers['Content-Type']).to eq('application/zip')
        expect(response.headers['Content-Disposition']).to eq("attachment; filename=\"#{file_name}_#{filestream_id}.zip\"")
      end
    end
  end
end
