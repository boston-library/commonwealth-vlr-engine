# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CommonwealthVlrEngine::Media::VideoPlayerComponent, type: :component do
  let(:mock_controller) { CatalogController.new }
  let(:item_pid) { 'bpl-dev:cj82k894f' }
  let(:document) { SolrDocument.find(item_pid) }
  let(:object_files) { mock_controller.get_files(item_pid) }

  it 'renders the component' do
    render_inline(described_class.new(document: document, object_files: object_files))

    expect(page.find('video')[:'src']).to include(object_files[:video].first['id'])
    expect(page.find('video')[:'poster']).to include(object_files[:video].first['id'])
    expect(page.find('track')[:'src']).to include(object_files[:video].first['id'])
  end
end
