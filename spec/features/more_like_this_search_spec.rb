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
    visit catalog_index_path(:mlt_id => 'bpl-dev:df65v790j', :qt => 'mlt')
    expect(page).to have_selector('#appliedParams span.mlt')
  end

end