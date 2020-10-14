require 'rails_helper'

describe 'show volumes list', js: true do
  before(:each) do
    visit solr_document_path(id: 'bpl-dev:3j334b469')
  end

  it 'displays the volumes list' do
    expect(page).to have_selector('#volumes_wrapper')
  end

  it 'should hide the read and download links' do
    expect(page).to have_selector('a.book_viewer_link', visible: false)
  end

  # TODO: fix volume display?
  # (or deprecate volumes and delete this file and all other volume stuff)
  it 'displays the read, search, and download links when the volume title is clicked' do
    click_link('V.1')
    expect(page).to have_selector('.book_viewer_link', visible: true)
    expect(page).to have_selector('.search_inside_link', visible: true)
    expect(page).to have_selector('.download_volume_links', visible: true)
  end
end
