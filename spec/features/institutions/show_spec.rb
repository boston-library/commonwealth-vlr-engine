require 'spec_helper'

describe 'Institutions#show view', js: true do

  before { visit institution_path(id: 'bpl-dev:abcd12345') }

  describe 'description collapse behavior' do

    describe 'collapsed description' do
      it 'should hide the #institution_desc_collapse content' do
        expect(page).to have_selector('#institution_desc_collapse', visible: false)
      end
    end

    describe 'expanded description' do

      before do
        page.find('.institution_desc_expand').click
      end

      it 'should show the #institution_desc_collapse content when the link is clicked' do
        expect(page).to have_selector('#institution_desc_collapse', visible: true)
      end

    end

  end


end