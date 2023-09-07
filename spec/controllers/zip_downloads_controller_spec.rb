# frozen_string_literal: true

require 'rails_helper'

describe ZipDownloadsController, :vcr do
  render_views

  let(:item_id) { 'bpl-dev:h702q6403' }
  let(:filestream_id) { 'image_access_800' }

  describe "GET 'trigger_download'" do
    # value of objects identifier_local_accession_tsim field is actually '13_05_000029',
    # but for some reason test Solr strips underscores
    let(:file_name) { "1305000029_#{filestream_id}.zip" }

    it 'should be successful and set the right headers' do
      get :trigger_download, params: { id: item_id, filestream_id: filestream_id }
      expect(response).to be_successful
      expect(response.headers['Content-Type']).to eq('application/zip')
      expect(response.headers['Content-Disposition']).to include("attachment; filename=\"#{file_name}\"")
    end
  end
end
