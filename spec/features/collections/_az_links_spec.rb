require 'spec_helper'

include CommonwealthVlrEngine::CollectionsHelperBehavior

# set this helper to return true so AZ links are rendered
def should_render_col_az?
  true
end

describe 'collections a-z links' do

  it 'should show the a-z links' do
    visit collections_path
    within ('#collection_az_links') do
      expect(page).to have_selector('.col_a-z_link')
    end
  end

  it 'should show correct results after clicking a letter link' do
    visit collections_path
    within ('#collection_az_links') do
      click_link('C')
    end
    expect(page).to have_selector('.document-title-heading', :text => 'Carte de Visite Collection')
  end

end