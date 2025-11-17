# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'image viewer modal behavior', :vcr, js: true do
  before(:each) do
    visit solr_document_path(id: 'bpl-dev:qf85nb285')
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
