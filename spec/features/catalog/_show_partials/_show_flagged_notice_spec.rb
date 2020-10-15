require 'rails_helper'

describe 'flagged item modal', js: true do
  before(:each) do
    visit solr_document_path(id: 'bpl-dev:00000007x')
  end

  it 'displays the flagged item modal when the page is loaded' do
    expect(page).to have_selector('#flagged_warning', visible: true)
  end

  it 'returns to the search page when the "back" button is clicked' do
    click_link('Back to Search')
    expect(page).to have_selector('#basic_search')
  end

  it 'should hide the flagged item modal when the accept button is clicked' do
    click_button('View Content')
    expect(page).to have_selector('#flagged_warning', visible: false)
  end
end
