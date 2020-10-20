# frozen_string_literal: true

require 'rails_helper'

describe 'Collections#show view', js: true do
  before(:each) { visit collection_path(id: 'bpl-dev:000000000') }

  describe 'facets' do
    it 'has facet links that route to catalog#index' do
      within('.blacklight-genre_basic_ssim') do
        click_button('Format')
        within('#facet-genre_basic_ssim') do
          expect(page).to have_selector("a[href*='/search?']")
        end
      end
    end

    describe 'click on "more" facet link' do
      before(:each) do
        within('.blacklight-subject_facet_ssim') do
          click_button('Topic')
          within('.more_facets') do
            click_link
          end
        end
      end

      it 'has facet links that route to catalog#index' do
        within('.facet-extended-list') do
          expect(page).to have_selector("a[href*='/search?']")
        end
      end
    end
  end
end
