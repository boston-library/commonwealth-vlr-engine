# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CommonwealthVlrEngine::Media::PdfViewerComponent, type: :component do
  let(:mock_controller) { CatalogController.new }
  let(:item_pid) { 'bpl-dev:z029pg62r' }
  let(:document) { SolrDocument.find(item_pid) }
  let(:object_files) { mock_controller.get_files(item_pid) }

  it 'renders the component' do
    render_inline(described_class.new(document: document, object_files: object_files))

    expect(page).to have_selector('#pdf_show_canvas')
    expect(page.find('object')[:'data']).to include(object_files[:document].first['id'])
  end
end
