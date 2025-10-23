# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CommonwealthVlrEngine::Document::DownloadsComponent, type: :component do
  let(:mock_controller) { DownloadsController.new }
  let(:item_pid) { 'bpl-dev:h702q6403' }
  let(:document) { SolrDocument.find(item_pid) }
  let(:video_pid) { 'bpl-dev:cj82k895q' }
  let(:document_pid) { 'bpl-dev:ff365636z' }
  let(:files_hash) do
    fh = mock_controller.get_files(item_pid)
    # add a video and document file so we can test download links
    fh[:video] = [SolrDocument.find(video_pid)]
    fh[:document] = [SolrDocument.find(document_pid)]
    fh
  end

  it 'renders the component' do
    render_inline(described_class.new(document: document, object_files: files_hash))

    expect(page).to have_css('li.download_list_item a.sidebar_downloads_link', count: 5)
    expect(page).to have_link(I18n.t('blacklight.downloads.images.image_primary'), href: "/downloads/#{item_pid}?filestream_id=image_primary")
    expect(page).to have_link('39999074400019_0', href: "/downloads/#{video_pid}?filestream_id=video_access_mp4")
    expect(page).to have_link('FreemensOath-Transcription', href: "/downloads/#{document_pid}?filestream_id=text_plain")
  end
end
