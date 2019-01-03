require 'rails_helper'

describe 'show book viewer link', js: true do

  before(:each) do
    visit solr_document_path(:id => 'bpl-dev:7s75dn48d')
  end

  it 'should display the read link' do
    expect(page).to have_selector('.book_viewer_link')
  end

  describe 'search inside link' do

    it 'should display the search link' do
      expect(page).to have_selector('.search_inside_link')
    end

    describe 'search inside modal' do

      before { click_link(I18n.t('blacklight.ocr.search.link')) }

      it 'should render the search inside partial as a Bootstrap modal within the page' do
        expect(page).to have_selector('.modal-header')
        expect(page).to have_selector('#item_metadata')
      end

      describe 'preserve the modal view' do

        before do
          within 'form.ocr-search-form' do
            fill_in 'ocr_q', with: 'instruction'
            click_button('search')
          end
        end

        it 'should display the results in the modal window within the page' do
          expect(page).to have_selector('#item_metadata')
        end

      end

    end

  end

end
