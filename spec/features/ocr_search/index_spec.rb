require 'spec_helper'

describe 'OCR search index view' do

  let(:book_pid) { 'bpl-dev:7s75dn48d' }

  describe 'with no search params' do
    it 'should display the search form' do
      visit ocr_search_path(id: book_pid)
      expect(page).to have_selector('form.ocr-search-form')
    end
  end

  describe 'with search params' do

    before { visit ocr_search_path(id: book_pid) }

    describe 'no matches' do
      it 'should render the no matches partial' do
        within 'form.ocr-search-form' do
          fill_in 'ocr_q', with: 'sdfsdf'
          click_button('search')
        end
        expect(page).to have_selector('#zero_results_ocr')
      end
    end

    describe 'with matches' do

      before do
        within 'form.ocr-search-form' do
          fill_in 'ocr_q', with: 'instruction'
          click_button('search')
        end
      end

      it 'should display the search results' do
        expect(page).to have_selector('.ocr_search_result', count: 2)
      end

      it 'should display the search term highlighting and page link' do
        expect(page).to have_selector('.ocr_page_link', count: 2)
        expect(page).to have_selector('.ocr_snippet', count: 2)
      end

    end

  end

end