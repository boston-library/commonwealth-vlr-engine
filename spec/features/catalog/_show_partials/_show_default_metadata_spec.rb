require 'spec_helper'

describe 'show book viewer link', js: true do

  before(:each) do
    visit solr_document_path(:id => 'bpl-dev:h702q6403')
  end

  it 'should not show #item_metadata_expand' do
    expect(page).to have_selector('#item_metadata_expand', visible: :hidden)
  end

  describe 'expanded metadata' do

    before do
      page.find('#metadata_expand_heading').click
    end

    it 'should show the #item_metadata_expand content when the link is clicked' do
      expect(page).to have_selector('#item_metadata_expand.collapse.in', visible: true)
    end

  end

end