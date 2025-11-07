# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'fielded_search' do
  it 'should show correct results after running a fielded search' do
    visit blacklight_advanced_search_engine.advanced_search_path
    within '#advanced_search_form' do
      within all('.advanced-search-field')[0] do
        select('Title', from: 'clause_0_field')
        fill_in 'clause_0_query', with: 'Beauregard'
      end
      click_button('advanced-search-submit')
    end
    expect(page).to have_selector('#documents .document', count: 1)
    expect(page).to have_selector('.document-title-heading', text: 'Beauregard')
  end
end
