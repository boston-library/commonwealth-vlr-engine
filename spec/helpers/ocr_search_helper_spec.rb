require 'rails_helper'

describe OcrSearchHelper do
  let(:blacklight_config) { CatalogController.blacklight_config }
  let(:ocr_search_helper_test_class) { OcrSearchController.new }
  let(:book_pid) { 'bpl-dev:7s75dn48d' }
  let(:book_document) { SolrDocument.find(book_pid) }

  before(:each) do
    allow(helper).to receive_messages(blacklight_config: blacklight_config)
  end

  describe '#has_searchable_text?' do
    it 'returns true if the item has searchable text' do
      expect(helper.has_searchable_text?(book_document)).to be_truthy
    end
  end

  describe '#ocr_q_params' do
    let(:current_search_session) { double(query_params: { 'q' => 'foo' }) }

    it 'returns the query params if they exist' do
      expect(helper.send(:ocr_q_params, current_search_session)).to eq('foo')
    end
  end

  describe '#render_page_link' do
    let(:page_pid) { 'bpl-dev:7s75dn58n' }
    let(:page_document) { SolrDocument.find(page_pid) }
    let(:image_pid_list) { ocr_search_helper_test_class.image_file_pids(ocr_search_helper_test_class.get_image_files(book_pid)) }

    describe 'with a page_num_field value' do
      let(:ocr_page_link) { helper.render_page_link(page_document, image_pid_list, book_pid) }

      it 'creates a link to the book viewer' do
        expect(ocr_page_link).to include("href=\"/book_viewer/#{book_pid}#?&amp;cv=0")
      end

      it 'has the correct label' do
        expect(ocr_page_link).to include(page_document[blacklight_config.page_num_field.to_sym])
      end
    end

    describe 'without page_num_field value' do
      let(:page_without_number) do
        no_page_num = page_document.to_h
        no_page_num[blacklight_config.page_num_field] = nil
        SolrDocument.new(no_page_num)
      end
      let(:ocr_page_link) { helper.render_page_link(page_without_number, image_pid_list, book_pid) }

      it 'has the correct label' do
        expect(ocr_page_link).to include('Image 1')
      end
    end
  end
end
