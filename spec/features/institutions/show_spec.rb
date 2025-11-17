# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'institutions#show view', :vcr, js: true do
  before(:each) { visit institution_path(id: 'bpl-dev:abcd12345') }

  describe 'description collapse behavior' do
    describe 'collapsed description' do
      it 'should hide the #institution_desc_collapse content' do
        expect(page).to have_selector('#institution_desc_collapse', visible: :hidden)
      end
    end

    describe 'expanded description' do
      # before(:each) { find('.institution_desc_expand').click }

      it 'should show the #institution_desc_collapse content when the link is clicked' do
        find('#institution_desc_expand').click
        expect(page).to have_selector('#institution_desc_collapse', visible: :visible)
      end
    end
  end
end
