# frozen_string_literal: true

require 'rails_helper'

# testing custom date range functionality added in
# app/components/commonwealth_vlr_engine/advanced_search_form_component.html.erb
RSpec.describe 'advanced search date range behavior', js: true do
  before(:each) { visit blacklight_advanced_search_engine.advanced_search_path }

  it 'should show the date range fields on the advanced search form' do
    expect(page).to have_selector('#range_date_facet_yearly_itim_begin')
    expect(page).to have_selector('#range_date_facet_yearly_itim_end')
  end

  describe 'submitting data', js: true do
    before(:each) do
      within '#date_range_limit' do
        fill_in 'range_date_facet_yearly_itim_begin', with: '1800'
        fill_in 'range_date_facet_yearly_itim_end', with: '1900'
      end
      click_button('advanced-search-submit')
    end

    it 'should show some search results' do
      expect(page).to have_selector('#documents .document', count: 4)
    end

    it 'should not show results from outside the date range' do
      expect(page).to_not have_selector("a[href*='bpl-dev:7s75dn48d']")
    end

    it 'should show the date range in the constraints' do
      expect(page).to have_selector('#appliedParams .filter-date_facet_yearly_itim')
    end
  end
end
