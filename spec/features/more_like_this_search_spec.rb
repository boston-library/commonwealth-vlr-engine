require 'spec_helper'

describe 'more like this search' do

  it 'should show the more-like-this search link' do
    visit solr_document_path(:id => 'bpl-dev:df65v790j')
    within ('#more_like_this') do
      expect(page).to have_selector('#more_mlt_link')
    end
  end

  it 'should show related results after clicking the link' do
    visit solr_document_path(:id => 'bpl-dev:df65v790j')
    click_link('more_mlt_link')
    expect(page).to have_selector('#documents div.document')
  end

  it 'should show the constraint for a more-like-this search' do
    visit search_catalog_path(:mlt_id => 'bpl-dev:df65v790j')
    expect(page).to have_selector('#appliedParams span.mlt')
  end

  describe 'show view from mlt search', js: true do

    before do
      visit search_catalog_path(:mlt_id => 'bpl-dev:df65v790j')
      page.find('#documents :first-child .thumbnail .caption a').click
    end

    it 'should show the previous-next links' do
      expect(page).to have_selector('.page_links .previous')
    end

    it 'should show the correct item count' do
      expect(page).to have_selector('.page_links strong:last-of-type', text: '4')
    end

  end

end