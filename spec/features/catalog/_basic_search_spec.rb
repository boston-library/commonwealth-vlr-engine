# frozen_string_literal: true

require 'rails_helper'

describe 'basic_search', js: true do
  before(:each) do
    visit search_catalog_path
  end

  it 'shows correct results after running a fielded search' do
    within '#basic_search_form_wrapper' do
      select('Title', from: 'search_field')
      fill_in 'q', with: 'parking'
      click_button('search')
    end
    expect(page).to have_selector('.document', count: 1)
    expect(page).to have_selector('.document-title-heading',
                                  text: 'Boston traffic map showing one way streets and parking spaces')
  end

  it 'shows correct results after running a full-text search' do
    within '#basic_search_form_wrapper' do
      find('#fulltext_checkbox').click
      fill_in 'q', with: 'assistance'
      click_button('search')
    end
    expect(page).to have_selector('.document', count: 1)
    expect(page).to have_selector('.document-title-heading',
                                  text: 'Outline lessons in housekeeping')
  end

  it 'unchecks the full-text checkbox when a non-full-text index is selected' do
    within '#basic_search_form_wrapper' do
      find('#fulltext_checkbox').click
      select('Title', from: 'search_field')
      expect(page).to_not have_checked_field('fulltext_checkbox')
    end
  end
end
