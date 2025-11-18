# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CommonwealthVlrEngine::Media::ImageViewerComponent, type: :component do
  let(:mock_controller) { CatalogController.new }
  let(:item_pid) { 'bpl-dev:00000003t' }
  let(:document) { SolrDocument.find(item_pid) }
  let(:object_files) { mock_controller.get_files(item_pid) }

  it 'renders the component' do
    render_inline(described_class.new(document: document, object_files: object_files))

    expect(page).to have_css('#img_viewer_title', text: document['title_info_primary_tsi'])
    expect(page.find('.img_show')[:'src']).to include(CommonwealthVlrEngine.config[:asset_store_url])
    expect(page.find('#img_viewer_osd')[:'data-tilesource']).to include(object_files[:image].first['id'])
  end
end
