# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'collections#index facet dropdown' do
  before(:each) { visit collections_path }

  describe 'facets' do
    it 'should show facet dropdowns' do
      expect(page).to have_selector('#genre_basic_ssim-dropdown')
      expect(page).to have_selector('#physical_location_ssim-dropdown')
    end

    it 'should not show "Collections" in the facet list for basic genre' do
      within('#genre_basic_ssim-dropdown') do
        expect(page.text).to_not include('Collections')
      end
    end

    it 'has facet links that route to collections#index' do
      within('#genre_basic_ssim-dropdown') do
        expect(page).to have_selector("a[href*='/collections?']")
      end
    end

    describe 'click on facet value' do
      it 'should show the facet limit in the applied params widget' do
        within('#genre_basic_ssim-dropdown') do
          click_link('Photographs')
        end
        within('.constraint-value') do
          expect(page.text).to include('Photographs')
        end
      end
    end
  end
end
