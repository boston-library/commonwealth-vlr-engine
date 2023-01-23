# frozen_string_literal: true

require 'rails_helper'

describe 'basic_search' do
  it 'shows correct results after running a fielded search' do
    visit search_catalog_path
    within '#basic_search_form' do
      select('Title', from: 'search_field')
      fill_in 'q', with: 'Beauregard'
      click_button('search')
    end
    expect(page).to have_selector('.document', count: 1)
    expect(page).to have_selector('.document-title-heading',
                                  text: 'Beauregard')
  end

  it 'shows correct results after running a full-text search' do
    visit search_catalog_path
    within '#basic_search_form' do
      find('#fulltext_checkbox').click
      fill_in 'q', with: 'assistance'
      click_button('search')
    end
    expect(page).to have_selector('.document', count: 1)
    expect(page).to have_selector('.document-title-heading',
                                  text: 'Outline lessons in housekeeping')
  end
end
