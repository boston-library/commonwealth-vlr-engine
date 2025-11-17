# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'flagged modal', :vcr, js: true do
  before(:each) do
    visit solr_document_path(id: 'bpl-dev:00000007x')
  end

  it 'displays the flagged item modal when the page is loaded' do
    expect(page).to have_selector('#flagged_warning_modal', visible: :visible)
  end

  it 'returns to the search page when the "back" button is clicked' do
    click_link(I18n.t('blacklight.back_to_search'))
    expect(page).to have_selector('#basic_search')
  end

  # have to use `visible: false`, spec mysteriously fails with `visible: :hidden`
  it 'should hide the flagged item modal when the accept button is clicked' do
    click_button('View Content')
    expect(page).to have_selector('#flagged_warning_modal', visible: false)
  end
end
