# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DownloadsHelper do
  let(:blacklight_config) { CatalogController.blacklight_config }
  let(:mock_controller) { DownloadsController.new }
  let(:item_ark_id) { 'bpl-dev:h702q6403' }
  let(:image_ark_id) { 'bpl-dev:h702q641c' }
  let(:image_document) { SolrDocument.find(image_ark_id) }
  let(:document) { SolrDocument.find(item_ark_id) }
  let(:video_ark_id) { 'bpl-dev:cj82k895q' }
  let(:document_ark_id) { 'bpl-dev:ff365636z' }
  let(:files_hash) do
    fh = mock_controller.get_files(item_ark_id)
    # add a video and document file so we can test download links
    fh[:video] = [SolrDocument.find(video_ark_id)]
    fh[:document] = [SolrDocument.find(document_ark_id)]
    fh
  end
  let(:object_profile) { JSON.parse(files_hash[:image].first['attachments_ss']) }
  let(:image_filestreams) do
    downloads_component = CommonwealthVlrEngine::Document::DownloadsComponent.new(document: document,
                                                                                  object_files: files_hash)
    downloads_component.image_filestreams(object_profile)
  end

  before(:each) do
    without_partial_double_verification do
      allow(helper).to receive_messages(blacklight_config: blacklight_config)
    end
  end

  describe '#has_downloadable_files?' do
    it 'returns true if there are documents, audio, or generic files' do
      expect(helper.has_downloadable_files?(document, files_hash)).to be_truthy
    end
  end

  describe '#has_downloadable_images?' do
    it 'returns true if there are image files and the license allows download' do
      expect(helper.has_downloadable_images?(document, files_hash)).to be_truthy
    end
  end

  describe '#has_downloadable_video?' do
    it 'returns true if there are video files and correct license' do
      expect(helper.has_downloadable_video?(document, files_hash)).to be_truthy
    end
  end

  describe '#ia_download_title' do
    it 'returns the correct download title' do
      expect(helper.ia_download_title('ebook_access_mobi', 'mobi')).to eq('Kindle')
      expect(helper.ia_download_title('ebook_access_daisy', 'zip')).to eq('Daisy')
    end
  end

  describe '#license_allows_download?' do
    it 'returns true if the license allows download' do
      expect(helper.license_allows_download?(document)).to be_truthy
    end
  end

  describe '#file_type_string' do
    it 'returns the correct file type' do
      expect(helper.file_type_string(image_filestreams[0], object_profile)).to eq('TIF')
      expect(helper.file_type_string(image_filestreams[1], nil)).to eq('JPEG')
    end
  end

  describe '#file_size_string' do
    it 'returns the correct file size' do
      expect(helper.file_size_string(image_filestreams[0], object_profile)).to eq('230 MB')
      expect(helper.file_size_string(image_filestreams[1], nil)).to eq('multi-file ZIP')
    end
  end

  describe '#public_domain?' do
    it 'returns true if the item is pre-1923 or has an explicit rights/license statement' do
      expect(helper.public_domain?(document)).to be_truthy
    end
  end

  describe '#url_for_download' do
    it 'returns the correct link path for a single-file item' do
      expect(helper.url_for_download(image_document, image_filestreams[0])).to include(
        trigger_downloads_path(image_ark_id, filestream_id: image_filestreams[0])
      )
    end

    it 'returns the correct link path for a multi-file item' do
      expect(helper.url_for_download(document, image_filestreams[0])).to include(
        trigger_zip_downloads_path(item_ark_id, filestream_id: image_filestreams[0])
      )
    end

    describe 'item from Internet Archive' do
      let(:document_to_hash) { document.to_h }
      before(:each) { document_to_hash['identifier_ia_id_ssi'] = 'foo' }

      it 'returns the correct link path for an Internet Archive item' do
        expect(helper.url_for_download(SolrDocument.new(document_to_hash), 'JPEG2000')).to include('archive.org')
      end
    end
  end
end
