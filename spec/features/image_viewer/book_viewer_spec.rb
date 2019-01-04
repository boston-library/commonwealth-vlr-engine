require 'rails_helper'

describe 'book_viewer', js: true do

  let(:book_pid) { 'bpl-dev:7s75dn48d' }
  let(:ocr_search_param) { 'ocr_q' }
  let(:ocr_search_term) { 'instruction' }

  describe 'search behavior' do

    before do
      visit book_viewer_path(:id => book_pid)
      click_link('toggle-search')
    end

    it 'should render the search inside partial as a Bootstrap modal within the page' do
      expect(page).to have_selector('.modal-header')
      expect(page).to have_selector('.blacklight-image_viewer')
    end

    describe 'running a search' do

      before do
        within 'form.ocr-search-form' do
          fill_in ocr_search_param, with: ocr_search_term
          click_button('search')
        end
      end

      it 'should display the results in the modal window within the page' do
        expect(page).to have_selector('.modal-header')
        expect(page).to have_selector('.blacklight-image_viewer')
      end

      describe 'linking to page' do

        before do
          click_link('Page 5')
        end

        it 'should go to the correct page' do
          expect(page).to have_selector('div.page.current img[src*="bpl-dev:7s75dn59x"]')
        end

        it 'should update the URL' do
          expect(current_url).to include("#{ocr_search_param}=#{ocr_search_term}#1/2")
        end

        describe 'starting a new search' do

          before do
            find('#toggle-search').click
          end

          it 'should display the results for the most recent search' do
            expect(page).to have_selector('#ocr_search_details')
          end

        end

      end

    end

  end

end
