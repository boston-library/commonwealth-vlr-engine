require 'spec_helper'

include CommonwealthVlrEngine::InstitutionsHelperBehavior

# set this helper to return true so AZ links are rendered
def should_render_inst_az?
  true
end

describe 'Institutions#index view' do #, js: true do

  before { visit institutions_path }

  # this is really a test for CommonwealthVlrEngine::Controller#search_action_path
  describe 'search_action_path' do

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

end