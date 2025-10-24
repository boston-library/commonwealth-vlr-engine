# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CommonwealthVlrEngine::Media::AudioPlayerComponent, type: :component do
  let(:mock_controller) { CatalogController.new }
  let(:item_pid) { 'bpl-dev:5d86p086p' }
  let(:document) { SolrDocument.find(item_pid) }
  let(:object_files) { mock_controller.get_files(item_pid) }

  it 'renders the component' do
    render_inline(described_class.new(document: document, object_files: object_files))

    expect(page).to have_css('#audio_show_container', text: object_files[:audio].first['filename_base_ssi'])
    expect(page).to have_selector('#audio_player')
  end
end
