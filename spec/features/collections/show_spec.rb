require 'rails_helper'

#include CommonwealthVlrEngine::CollectionsHelperBehavior

describe 'Collections#index view', js: true do

  before { visit collection_path(:id => 'bpl-dev:000000000') }

  describe 'facets' do

    it 'should have facet links that route to catalog#index' do
      within ('#facet-genre_basic_ssim') do
        expect(page).to have_selector("a[href*='/search?']")
      end
    end

    describe 'click on "more" facet link' do

      before do
        begin
          within ('#facet-subject_facet_ssim') do
            click_link('Topic')
            within ('li.more_facets_link') do
              click_link('more Topic »')
            end
          end
        rescue Capybara::RackTest::Errors::StaleElementReferenceError => e
          puts "Don't Know why this is happening but it doesnt break the test below"
          puts e.message
        end
      end

      it 'should have facet links that route to catalog#index' do
        within ('.facet_extended_list') do
          expect(page).to have_selector("a[href*='/search?']")
        end
      end

    end

  end

end
