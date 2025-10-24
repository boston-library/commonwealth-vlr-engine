# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CommonwealthVlrEngine::Media::BookViewerComponent, type: :component do
  let(:mock_controller) { CatalogController.new }
  let(:item_pid) { 'bpl-dev:7s75dn48d' }
  let(:document) { SolrDocument.find(item_pid) }
  let(:object_files) { mock_controller.get_files(item_pid) }

  it 'renders the component' do
    render_inline(described_class.new(document: document, object_files: object_files))

    expect(page).to have_css('#uv')
    expect(page.find('#uv')[:'data-uvconfig']).to be_truthy
    expect(page.find('#uv')[:'data-manifest']).to be_truthy
  end
end
