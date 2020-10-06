require 'rails_helper'

describe 'Institutions#index map view', js: true do

  before { visit institutions_path(:view => 'maps') }

  it 'should show map marker' do
    within ('#institutions-index-map') do
      expect(page).to have_selector('.leaflet-marker-icon')
    end
  end

  describe 'click marker cluster' do

    before { find('div.leaflet-marker-icon').click }

    it 'should show the search_form_institution content' do
      within ('div.leaflet-popup-content') do
        expect(page.text).to include('institution')
      end
    end

    describe 'constraints links' do

      before { find('div.leaflet-popup-content a').click }

      it 'has .constraints > a.remove that links to institutions#index' do
        within ('#appliedParams') do
          expect(page.html).to include('/institutions?')
        end
      end

    end

  end

end