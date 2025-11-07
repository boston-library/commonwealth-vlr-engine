# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'flagged modal', :vcr, js: true do
  before(:each) do
    visit solr_document_path(id: 'bpl-dev:00000007x')
  end

  it 'displays the flagged item modal when the page is loaded' do
    expect(page).to have_selector('#flaggedWarningTitle', visible: :visible)
  end

  it 'returns to the search page when the "back" button is clicked' do
    click_link('Back to Search')
    expect(page).to have_selector('#basic_search')
  end

  it 'should hide the flagged item modal when the accept button is clicked' do
    click_button('View Content')
    expect(page).to have_selector('#flaggedWarningTitle', visible: :hidden)
  end
end
