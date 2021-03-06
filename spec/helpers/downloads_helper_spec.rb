# frozen_string_literal: true

require 'rails_helper'

describe DownloadsHelper do
  let(:blacklight_config) { CatalogController.blacklight_config }
  let(:downloads_helper_test_class) { DownloadsController.new }
  let(:item_pid) { 'bpl-dev:h702q6403' }
  let(:image_pid) { 'bpl-dev:h702q641c' }
  let(:document) { SolrDocument.find(item_pid) }
  let(:files_hash) { downloads_helper_test_class.get_files(item_pid) }
  let(:object_profile) { JSON.parse(files_hash[:images].first['object_profile_ssm'].first) }
  let(:download_links) { helper.create_download_links(document, files_hash) }
  let(:image_datastreams_output) { helper.image_datastreams(object_profile) }

  before(:each) do
    allow(helper).to receive_messages(blacklight_config: blacklight_config)
    # copy :images to :documents/:video, as don't have any non-image items to test with at the moment
    files_hash[:documents] = [files_hash[:images].first]
    files_hash[:video] = [files_hash[:images].last]
  end

  describe '#create_download_links' do
    it 'returns an array of links' do
      expect(download_links.length).to eq(5)
      expect(download_links.first.match(/\A<a[a-z -=\\"_]*href=/)).to be_truthy
    end
  end

  describe '#download_link_class' do
    it 'returns a string' do
      expect(helper.download_link_class.class).to eq(String)
    end
  end

  describe '#download_link_options' do
    it 'returns a Hash of link options' do
      expect(helper.download_link_options[:class]).to be_truthy
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
      expect(helper.ia_download_title('mobi')).to eq('Kindle')
      expect(helper.ia_download_title('zip')).to eq('Daisy')
    end
  end

  describe '#image_datastreams' do
    it 'returns an array of image datastream ids' do
      expect(image_datastreams_output.class).to eq(Array)
      expect(image_datastreams_output[0]).to eq('productionMaster')
    end
  end

  describe '#image_download_links' do
    let(:image_download_links) { helper.image_download_links(document, files_hash[:images]) }

    it 'returns an array of links' do
      expect(image_download_links.length).to eq(3)
      expect(image_download_links.first.match(/\A<a[a-z -=\\"_]*href=/)).to be_truthy
    end
  end

  describe '#video_download_links' do
    let(:video_download_links) { helper.video_download_links(document, files_hash[:video]) }

    it 'returns an array of links' do
      expect(video_download_links.length).to eq(1)
      expect(video_download_links.first.match(/\A<a[a-z -=\\"_]*href=/)).to be_truthy
    end
  end

  describe '#other_download_links' do
    let(:other_download_links) { helper.other_download_links(document, files_hash) }

    it 'returns an array of links' do
      expect(other_download_links.length).to eq(1)
      expect(other_download_links.first.match(/\A<a[a-z -=\\"_]*href=/)).to be_truthy
    end
  end

  describe '#license_allows_download?' do
    it 'returns true if the license allows download' do
      expect(helper.license_allows_download?(document)).to be_truthy
    end
  end

  describe '#file_download_link' do
    let(:file_download_link_output) do
      helper.file_download_link(image_pid, 'foo', object_profile, image_datastreams_output[0])
    end

    it 'returns a link' do
      expect(file_download_link_output.match(/\A<a[a-z -=\\"_]*href=/)).to be_truthy
    end

    it 'should link to the downloads controller show action with the correct datastream param' do
      expect(file_download_link_output).to include(download_path(image_pid, datastream_id: image_datastreams_output[0]))
    end

    it 'should include a <span> with the file type and size' do
      expect(file_download_link_output).to include('<span')
      expect(file_download_link_output).to include('TIF')
      expect(file_download_link_output).to include('10.5 MB')
    end
  end

  describe '#file_type_string' do
    it 'returns the correct file type' do
      expect(helper.file_type_string(image_datastreams_output[0], object_profile)).to eq('TIF')
      expect(helper.file_type_string(image_datastreams_output[1], nil)).to eq('JPEG')
    end
  end

  describe '#file_size_string' do
    it 'returns the correct file size' do
      expect(helper.file_size_string(image_datastreams_output[0], object_profile)).to eq('10.5 MB')
      expect(helper.file_size_string(image_datastreams_output[1], nil)).to eq('multi-file ZIP')
    end
  end

  describe '#public_domain?' do
    it 'returns true if the item is pre-1923 or has an explicit rights/license statement' do
      expect(helper.public_domain?(document)).to be_truthy
    end
  end

  describe '#setup_zip_object_profile' do
    let(:zip_object_profile) { helper.setup_zip_object_profile(files_hash[:images], image_datastreams_output[0]) }

    it 'returns a hash with the right structure' do
      expect(zip_object_profile['zip']).to be_truthy
      expect(zip_object_profile['datastreams'][image_datastreams_output[0]]['dsSize']).to be_truthy
    end

    # should be greater than 10.5 MB
    it 'should estimate the zip size' do
      expect(zip_object_profile['datastreams'][image_datastreams_output[0]]['dsSize'] > 11_010_048).to be_truthy
    end
  end

  describe '#url_for_download' do
    it 'returns the correct link path for a hosted item' do
      expect(helper.url_for_download(document, image_datastreams_output[0])).to include(trigger_downloads_path(item_pid,
                                                                                                               datastream_id: image_datastreams_output[0]))
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
