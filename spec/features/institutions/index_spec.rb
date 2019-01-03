require 'rails_helper'

describe 'Institutions#index view', js: true do
  before(:all) do
    CommonwealthVlrEngine::InstitutionsHelperBehavior.module_eval do
      def should_render_inst_az?
        true
      end
    end
  end
  before(:each) { visit institutions_path }
  # this is really a test for CommonwealthVlrEngine::Controller#search_action_path
  describe 'search_action_path' do
    # set this helper to return true so AZ links are rendered

    before do
      within 'div.item_az_links' do
        click_link('B')
      end
    end

    it 'should have the correct path in the Start Over link' do
      within ('#startOverLink') do
        expect(page.html).to include('/institutions')
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
end
