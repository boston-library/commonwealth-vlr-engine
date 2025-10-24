# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CommonwealthVlrEngine::Media::MultiImageViewerComponent, type: :component do
  let(:mock_controller) { CatalogController.new }
  let(:item_pid) { 'bpl-dev:h702q6403' }
  let(:document) { SolrDocument.find(item_pid) }
  let(:object_files) { mock_controller.get_files(item_pid) }

  it 'renders the component' do
    render_inline(described_class.new(document: document, object_files: object_files))

    expect(page.find('#multi_img_viewer_osd')[:'data-tilesources']).to be_truthy
    expect(page.find('#multi_img_viewer_osd')[:'data-navimages']).to be_truthy
  end
end
