# frozen_string_literal: true

require 'rails_helper'

describe 'advanced search date range behavior', js: true do
  before(:each) { visit blacklight_advanced_search_engine.advanced_search_path }

  it 'should show the date range fields on the advanced search form' do
    expect(page).to have_selector('#date_range_start')
    expect(page).to have_selector('#date_range_end')
  end

  describe 'submitting data', js: true do
    before(:each) do
      within '#date_range_limit' do
        fill_in 'date_range_start', with: '1800'
        fill_in 'date_range_end', with: '1900'
      end
      click_on('advanced_search')
    end

    it 'should show some search results' do
      expect(page).to have_selector('#documents .document')
    end

    it 'should not show results from outside the date range' do
      expect(page).to_not have_selector("a[href*='bpl-dev:7s75dn48d']")
    end

    it 'should show the date range in the constraints' do
      expect(page).to have_selector('#appliedParams .date_range')
    end
  end
end
