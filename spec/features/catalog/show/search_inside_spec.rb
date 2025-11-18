# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'search inside link', :vcr, js: true do
  before(:each) do
    visit solr_document_path(id: 'bpl-dev:th83m700n')
  end

  # vcr seems to sometimes have difficulty finding default cassette, set it explicitly
  VCR.use_cassette('search_inside_link/displays_the_search_link') do
    it 'displays the search link' do
      expect(page).to have_selector('#ocrSearchLink')
    end
  end

  describe 'search inside modal' do
    before(:each) { click_link(I18n.t('blacklight.ocr.search.link')) }

    it 'renders the search inside partial as a Bootstrap modal within the page' do
      expect(page).to have_selector('.modal-header')
      expect(page).to have_selector('#item_metadata')
    end

    describe 'preserve the modal view' do
      before(:each) do
        within '#ocr_search_form' do
          fill_in 'ocr_q', with: 'Dorchester'
          click_button('ocr_search')
        end
      end

      it 'displays the results in the modal window within the page' do
        expect(page).to have_selector('#item_metadata')
      end
    end
  end
end
