require 'spec_helper'

describe DownloadsHelper do

  class DownloadsHelperTestClass < CatalogController
    cattr_accessor :blacklight_config

    include Blacklight::SearchHelper
    include CommonwealthVlrEngine::Finder

    def initialize blacklight_config
      self.blacklight_config = blacklight_config
    end

  end

  let(:blacklight_config) { CatalogController.blacklight_config }
  let(:downloads_helper_test_class) { DownloadsHelperTestClass.new blacklight_config }
  let(:item_pid) { 'bpl-dev:h702q6403' }
  let(:image_pid) { 'bpl-dev:h702q641c' }
  let(:document) { Blacklight.default_index.search({:q => "id:\"#{item_pid}\"", :rows => 1}).documents.first }
  let(:files_hash) { downloads_helper_test_class.get_files(item_pid) }
  let(:object_profile) { JSON.parse(files_hash[:images].first['object_profile_ssm'].first) }

  before(:each) do
    allow(helper).to receive_messages(blacklight_config: blacklight_config)
  end

  before do
    # copy :images to :documents, since we don't have any non-image items to test with at the moment
    files_hash[:documents] = files_hash[:images]
    @download_links = helper.create_download_links(document, files_hash)
    @image_datastreams_output = helper.image_datastreams(object_profile)
  end

  describe '#create_download_links' do
    it 'should return an array of links' do
      expect(@download_links.length).to eq(5)
      expect(@download_links.first.match(/\A<a[a-z -=\\"_]*href=/)).to be_truthy
    end
  end

  describe '#download_link_class' do
    it 'should return a string' do
      expect(helper.download_link_class.class).to eq(String)
    end
  end

  describe '#download_link_options' do
    it 'should return a Hash of link options' do
      expect(helper.download_link_options[:class]).to be_truthy
    end
  end

  describe '#has_downloadable_files?' do
    it 'should return true if there are documents, audio, or generic files' do
      expect(helper.has_downloadable_files?(document, files_hash)).to be_truthy
    end
  end

  describe '#has_downloadable_images?' do
    it 'should return true if there are image files and the license allows download' do
      expect(helper.has_downloadable_images?(document, files_hash)).to be_truthy
    end
  end

  describe '#ia_download_title' do
    it 'should return the correct download title' do
      expect(helper.ia_download_title('mobi')).to eq('Kindle')
      expect(helper.ia_download_title('zip')).to eq('Daisy')
    end
  end

  describe '#image_datastreams' do
    it 'should return an array of image datastream ids' do
      expect(@image_datastreams_output.class).to eq(Array)
      expect(@image_datastreams_output[0]).to eq('productionMaster')
    end
  end

  describe '#image_download_links' do

    before do
      @image_download_links = helper.image_download_links(document, files_hash[:images])
    end

    it 'should return an array of links' do
      expect(@image_download_links.length).to eq(3)
      expect(@image_download_links.first.match(/\A<a[a-z -=\\"_]*href=/)).to be_truthy
    end

  end

  describe '#license_allows_download?' do
    it 'should return true if the license allows download' do
      expect(helper.license_allows_download?(document)).to be_truthy
    end
  end

  describe '#file_download_link' do

    let (:file_download_link_output) { helper.file_download_link(image_pid,
                                                                 'foo',
                                                                 object_profile,
                                                                 @image_datastreams_output[0]) }

    it 'should return a link' do
      expect(file_download_link_output.match(/\A<a[a-z -=\\"_]*href=/)).to be_truthy
    end

    it 'should link to the downloads controller show action with the correct datastream param' do
      expect(file_download_link_output).to include(download_path(image_pid, datastream_id: @image_datastreams_output[0]))
    end

    it 'should include a <span> with the file type and size' do
      expect(file_download_link_output).to include('<span')
      expect(file_download_link_output).to include('TIF')
      expect(file_download_link_output).to include('10.5 MB')
    end

  end

  describe '#file_type_string' do
    it 'should return the correct file type' do
      expect(helper.file_type_string(@image_datastreams_output[0], object_profile)).to eq('TIF')
      expect(helper.file_type_string(@image_datastreams_output[1], nil)).to eq('JPEG')
    end
  end

  describe '#file_size_string' do
    it 'should return the correct file size' do
      expect(helper.file_size_string(@image_datastreams_output[0], object_profile)).to eq('10.5 MB')
      expect(helper.file_size_string(@image_datastreams_output[1], nil)).to eq('multi-file ZIP')
    end
  end

  describe '#setup_zip_object_profile' do

    let (:zip_object_profile) { helper.setup_zip_object_profile(files_hash[:images], @image_datastreams_output[0]) }

    it 'should return a hash with the right structure' do
      expect(zip_object_profile['zip']).to be_truthy
      expect(zip_object_profile['datastreams'][@image_datastreams_output[0]]['dsSize']).to be_truthy
    end

    # should be greater than 10.5 MB
    it 'should estimate the zip size' do
      expect(zip_object_profile['datastreams'][@image_datastreams_output[0]]['dsSize'] > 11010048).to be_truthy
    end

  end

  describe '#url_for_download' do

    it 'should return the correct link path for a hosted item' do
      expect(helper.url_for_download(document, @image_datastreams_output[0])).to include(trigger_downloads_path(item_pid,
                                                                                                                datastream_id: @image_datastreams_output[0]))
    end

    describe 'item from Internet Archive' do

      let (:document_to_hash) { document.to_h }
      before { document_to_hash['identifier_ia_id_ssi'] = 'foo' }

      it 'should return the correct link path for an Internet Archive item' do
        expect(helper.url_for_download(SolrDocument.new(document_to_hash), 'JPEG2000')).to include('archive.org')
      end

    end

  end

end