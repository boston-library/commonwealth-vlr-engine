# frozen_string_literal: true

require 'rails_helper'

describe 'more like this search' do
  let(:mlt_item_pid) { 'bpl-dev:df65v790j' }

  it 'should show the more-like-this search link' do
    visit solr_document_path(id: mlt_item_pid)
    within('#more_like_this') do
      expect(page).to have_selector('#more_mlt_link')
    end
  end

  describe 'after clicking more_mlt_link' do
    before(:each) do
      visit solr_document_path(id: mlt_item_pid)
      click_link('more_mlt_link')
    end

    it 'should show related results after clicking the link' do
      expect(page).to have_selector('#documents div.document')
    end

    it 'should show the constraint for a more-like-this search' do
      expect(page).to have_selector('#appliedParams .constraint-value .filter-name', text: 'More Like')
    end
  end

  # for some reason specs below don't pass without js: true
  describe 'show view from mlt search', js: true do
    before(:each) do
      visit search_catalog_path(mlt_id: mlt_item_pid)
      page.find('#documents :first-child .thumbnail .caption a').click
    end

    it 'should show the previous-next links' do
      expect(page).to have_selector('.page-links .previous')
    end

    it 'should show the correct item count' do
      expect(page).to have_selector('.page-links strong:last-of-type', text: '5')
    end
  end
end
