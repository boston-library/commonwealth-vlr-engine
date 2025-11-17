# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'institutions#index view' do
  before(:each) { visit institutions_path }

  describe 'az_links search_action_path' do
    before(:each) do
      within '#az_links' do
        click_link('B')
      end
    end

    it 'has the correct path in the Start Over link' do
      within('#appliedParams') do
        expect(page).to have_selector("a[href*='/institutions']")
      end
    end
  end
end
