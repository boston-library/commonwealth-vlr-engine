require 'rails_helper'

describe 'basic_search' do
  it 'should show correct results after running a fielded search' do
    visit search_catalog_path
    within '#basic_search_form' do
      select('Title', from: 'basic_search_indexes')
      fill_in 'q_basic', with: 'Beauregard'
      click_button('search')
    end
    expect(page).to have_selector('.document', count: 1)
    expect(page).to have_selector('.document-title-heading',
                                  :text => 'Beauregard')
  end
end
