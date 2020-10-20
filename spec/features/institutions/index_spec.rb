# frozen_string_literal: true

require 'rails_helper'

describe 'Institutions#index view' do
  before(:all) do
    CommonwealthVlrEngine::InstitutionsHelperBehavior.module_eval do
      # set this helper to return true so AZ links are rendered
      def should_render_inst_az?
        true
      end
    end
  end

  after(:all) do
    CommonwealthVlrEngine::InstitutionsHelperBehavior.module_eval do
      def should_render_inst_az?
        false
      end
    end
  end

  before(:each) { visit institutions_path }

  # this is mostly a test for CommonwealthVlrEngine::Controller#search_action_path
  describe 'search_action_path' do
    before(:each) do
      within '#az_links' do
        click_link('B')
      end
    end

    it 'has the correct path in the Start Over link' do
      within('#start_over_wrapper') do
        expect(page).to have_selector("a[href*='/institutions']")
      end
    end
  end
end
