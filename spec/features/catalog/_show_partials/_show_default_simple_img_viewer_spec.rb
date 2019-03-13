require 'rails_helper'

describe 'openseadragon image viewer modal' do

  before do
    visit solr_document_path(:id => 'bpl-dev:h702q6403')
  end

  it 'should display the OSD viewer modal when the image is clicked', :js => true do
    find('#img_viewer_link').click
    expect(page).to have_selector('.openseadragon-container')
  end

  it 'should display the OSd viewer modal when the zoom icon is clicked', :js => true do
    click_link('img_show_zoom_cue')
    expect(page).to have_selector('.openseadragon-container')
  end

end
