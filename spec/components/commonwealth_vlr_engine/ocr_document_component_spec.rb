# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CommonwealthVlrEngine::OcrDocumentComponent, type: :component do
  subject(:component) { described_class.new(document: doc_presenter, **attr) }

  let(:ocr_controller) { OcrSearchController.new }
  let(:attr) do
    { image_pid_list: image_pid_list,
      counter_offset: 0,
      parent_ark_id: book_pid,
      ocr_q: 'foo' }
  end
  let(:view_context) { controller.view_context }
  let(:render) do
    component.render_in(view_context)
  end

  let(:rendered) do
    Capybara::Node::Simple.new(render)
  end

  let(:doc_presenter) { Blacklight::IndexPresenter.new(page_document, view_context) }


  let(:book_pid) { 'bpl-dev:7s75dn48d' }
  let(:page_pid) { 'bpl-dev:7s75dn58n' }
  let(:page_document) { SolrDocument.find(page_pid) }
  let(:image_pid_list) { ocr_controller.image_file_pids(ocr_controller.get_image_files(book_pid)) }

  let(:blacklight_config) do
    CatalogController.blacklight_config.deep_copy.tap do |config|
      config.add_index_field 'ocr_tsiv', highlight: true, helper_method: 'render_ocr_snippets'
      config.default_per_page = 5
      config.index.document_component = described_class
    end
  end

  before do
    # Every call to view_context returns a different object. This ensures it stays stable.
    without_partial_double_verification do
      allow(controller).to receive_messages(view_context: view_context, blacklight_config: blacklight_config)
      allow(view_context).to receive_messages(search_session: {}, current_search_session: nil, current_bookmarks: [])
    end
  end

  it 'renders the component' do
    # render_inline(described_class.new(document: Blacklight::IndexPresenter.new(page_document)))
    # puts "#{rendered_content}"

    expect(rendered).to have_selector('.ocr_search_result')
  end
end
