require 'spec_helper'

#include CommonwealthVlrEngine::CollectionsHelperBehavior

describe 'Collections#index view' do #, js: true do

  before { visit collections_path }

  describe 'facets' do

    it 'should show facets in the sidebar' do
      expect(page).to have_selector('.facet-content')
    end

    it 'should not show "Collections" in the facet list for basic genre' do
      within ('#facet-genre_basic_ssim') do
        expect(page.text).to_not include('Collections')
      end
    end

    describe 'click on facet value' do

      before { click_link('Photographs') }

      it 'should show the facet limit in the applied params widget' do
        within ('.constraint-value') do
          expect(page.text).to include('Photographs')
        end
      end

    end

  end

end