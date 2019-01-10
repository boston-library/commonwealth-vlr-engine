require 'rails_helper'

describe 'basic_search' do
  it 'should show correct results after running a fielded search' do
    visit blacklight_advanced_search_engine.advanced_search_path
    within '#advanced_search_form' do
      within all('.advanced_search_field')[0] do
        select('Title', from: 'search_index_')
        fill_in 'query_', with: 'Beauregard'
      end
      click_button('advanced_search')
    end
    expect(page).to have_selector('.document', count: 1)
    expect(page).to have_selector('.document-title-heading',
                                  :text => 'Beauregard')
  end
end
