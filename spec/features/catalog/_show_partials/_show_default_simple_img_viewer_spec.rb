require 'rails_helper'

describe 'openseadragon image viewer modal', js: true do
  before do
    visit solr_document_path(id: 'bpl-dev:h702q6403')
  end

  it 'displays the OSD viewer modal when the image is clicked' do
    find('#img_viewer_link').click
    expect(page).to have_selector('.openseadragon-container')
  end

  it 'displays the OSd viewer modal when the zoom icon is clicked' do
    click_link('img_show_zoom_cue')
    expect(page).to have_selector('.openseadragon-container')
  end
end
