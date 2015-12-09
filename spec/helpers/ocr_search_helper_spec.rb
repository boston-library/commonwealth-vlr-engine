require 'spec_helper'

describe OcrSearchHelper do

  class OcrSearchHelperTestClass < CatalogController
    cattr_accessor :blacklight_config

    include Blacklight::SearchHelper
    include CommonwealthVlrEngine::Finder
    include CommonwealthVlrEngine::CatalogHelper

    def initialize blacklight_config
      self.blacklight_config = blacklight_config
    end
  end

  let(:blacklight_config) { CatalogController.blacklight_config }
  let(:ocr_search_helper_test_class) { OcrSearchHelperTestClass.new blacklight_config }

  before(:each) do
    allow(helper).to receive_messages(blacklight_config: blacklight_config)
  end

  describe '#ocr_q_params' do

    let(:current_search_session) { double(:query_params => {'q' => 'foo'}) }

    it 'should return the query params if they exist' do
      expect(helper.send(:ocr_q_params, current_search_session)).to eq('foo')
    end

  end

  describe '#render_page_link' do

    let(:book_pid) { 'bpl-dev:7s75dn48d' }
    let(:page_pid) { 'bpl-dev:7s75dn58n' }
    let(:document) { Blacklight.default_index.search({:q => "id:\"#{page_pid}\"", :rows => 1}).documents.first }
    let(:image_pid_list) { ocr_search_helper_test_class.has_image_files?(ocr_search_helper_test_class.get_files(book_pid)) }

    describe 'with a page_num_field value' do

      before { @ocr_page_link = helper.render_page_link(document, image_pid_list, book_pid) }

      it 'should create a link to the book viewer' do
        expect(@ocr_page_link).to include("href=\"/book_viewer/#{book_pid}#1/1")
      end

      it 'should have the correct label' do
        expect(@ocr_page_link).to include(document[blacklight_config.page_num_field.to_sym])
      end

    end

    describe 'without page_num_field value' do

      before do
        document[blacklight_config.page_num_field.to_sym] = nil
        @ocr_page_link = helper.render_page_link(document, image_pid_list, book_pid)
      end

      it 'should have the correct label' do
        expect(@ocr_page_link).to include('Image 1 of 2')
      end

    end

  end

end