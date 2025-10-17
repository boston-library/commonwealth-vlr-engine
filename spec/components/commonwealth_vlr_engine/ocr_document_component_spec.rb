# frozen_string_literal: true

require 'rails_helper'

# there's a lof of setup here and code copied from OcrSearchController
# but to test rendering of term_freq and snippets
# we need an actual search response from Solr, can't just use a single document
RSpec.describe CommonwealthVlrEngine::OcrDocumentComponent, type: :component do
  subject(:component) { described_class.new(document: doc_presenter, **attr) }

  let(:ocr_q) { 'lessons' }
  let(:ocr_search_field) { 'ocr_tsiv' }
  let(:page_num_field) { 'page_num_label_ssi' }
  let(:ocr_controller) { OcrSearchController.new }
  let(:attr) do
    { image_pid_list: image_pid_list,
      parent_ark_id: book_pid,
      ocr_q: ocr_q,
      document_counter: 5
    }
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
  let(:ocr_search_params) do
    { q: ocr_q,
      f: { 'is_file_set_of_ssim' => book_pid,
           blacklight_config.index.display_type_field => 'Image' } } # curator_model_suffix_ssi
  end
  let(:search_service) do
    ocr_controller.search_service_class.new(config: blacklight_config, user_params: ocr_search_params,
                                            search_builder_class: CommonwealthVlrEngine::OcrSearchBuilder)
  end
  let(:response) { search_service.search_results }
  let(:page_document) { response.documents.first }
  let(:image_pid_list) { ocr_controller.image_file_pids(ocr_controller.get_image_files(book_pid)) }
  let(:blacklight_config) do
    CatalogController.blacklight_config.deep_copy.tap do |config|
      config.add_index_field ocr_search_field, highlight: true, helper_method: 'render_ocr_snippets'
      config.default_per_page = 5
      config.index.document_component = described_class
      config.default_solr_params[:fl] = "id,#{page_num_field},term_freq:termfreq(#{ocr_search_field},\"#{ocr_q}\")"
    end
  end

  before do
    without_partial_double_verification do
      allow(controller).to receive_messages(view_context: view_context, blacklight_config: blacklight_config)
    end
  end

  it 'renders the component' do
    expect(rendered).to have_selector('.ocr_search_result')
    expect(rendered).to have_css('.ocr_term_freq', text: "#{page_document[:term_freq]} matches")
    expect(rendered).to have_link "Page #{page_document[page_num_field]}", href: "/search/#{book_pid}#?&cv=1&h=#{ocr_q}"
    expect(rendered).to have_selector('.ocr_snippet')
  end
end
