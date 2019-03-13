require 'rails_helper'

describe CommonwealthVlrEngine::Finder do

  class FinderTestClass
    cattr_accessor :blacklight_config

    include Blacklight::SearchHelper
    include CommonwealthVlrEngine::Finder

    def initialize blacklight_config
      self.blacklight_config = blacklight_config
    end

  end

  let(:blacklight_config) { Blacklight::Configuration.new }

  before do
    @obj = FinderTestClass.new blacklight_config
    @item_pid = 'bpl-dev:h702q6403'
    @image1_pid = 'bpl-dev:h702q641c'
    @image2_pid = 'bpl-dev:h702q642n'
  end

  describe 'get_files' do

    let (:return_hash) { @obj.get_files(@item_pid) }

    it 'should create a hash with the file objects' do
      expect(return_hash.empty?).to be_falsey
      expect(return_hash.length).to eq(5)
    end

    it 'should have an :images key with a hash of Bplmodel::ImageFile SolrDocs as the value' do
      expect(return_hash[:images].length).to eq(2)
      expect(return_hash[:images][0].class).to eq(SolrDocument)
      expect(return_hash[:images][0]['active_fedora_model_ssi']).to eq('Bplmodels::ImageFile')
    end

    it 'should have the right ImageFile objects for the item' do
      expect(return_hash[:images].to_s).to include(@image1_pid)
    end

    describe 'sort_files' do

      it 'should have the images in the right order' do
        expect(return_hash[:images][0]['id']).to eq(@image1_pid)
        expect(return_hash[:images][1]['id']).to eq(@image2_pid)
      end

    end

  end

  describe 'get_image_files' do

    let(:pid) { 'bpl-dev:h702q6403' }
    let (:return_list) { @obj.get_image_files(pid) }

    it 'should create an array with the ImageFile objects' do
      expect(return_list.empty?).to be_falsey
      expect(return_list.length).to eq(2)
      expect(return_list[0]['active_fedora_model_ssi']).to eq('Bplmodels::ImageFile')
    end

    it 'should have the right ImageFile objects for the item, in the right order' do
      expect(return_list[0]['id']).to eq(@image1_pid)
    end

  end

  describe 'get_first_image_file' do

    let (:response) { @obj.get_first_image_file(@item_pid) }

    it 'should return the first ImageFile object' do
      expect(response).not_to be_nil
      expect(response['id']).to eq(@image1_pid)
    end

  end

  describe 'get_next_image_file' do

    let (:response) { @obj.get_next_image_file(@image1_pid) }

    it 'should return the next ImageFile object' do
      expect(response).not_to be_nil
      expect(response['id']).to eq(@image2_pid)
    end

  end

  describe 'get_prev_image_file' do

    let (:response) { @obj.get_prev_image_file(@image2_pid) }

    it 'should return the next ImageFile object' do
      expect(response).not_to be_nil
      expect(response['id']).to eq(@image1_pid)
    end

  end

  describe 'get_file_parent_object' do

    let (:response) { @obj.get_file_parent_object(@image2_pid) }

    it 'should return the parent object' do
      expect(response).to eq(@item_pid)
    end

  end

  describe 'get_volume_objects' do

    let(:pid) { 'bpl-dev:3j334b469' }
    let (:return_list) { @obj.get_volume_objects(pid) }

    it 'should return an array of hashes with the Volume objects and files' do
      expect(return_list.class).to eq(Array)
      expect(return_list.length).to eq(2)
      expect(return_list[0].class).to eq(Hash)
    end

    it 'should return the volume document in the :vol_doc value' do
      expect(return_list[0][:vol_doc].id).to eq('bpl-dev:3j334603p')
      expect(return_list[0][:vol_doc]['active_fedora_model_ssi']).to eq('Bplmodels::Volume')
    end

    it 'should return the volume files in the :vol_files value' do
      expect(return_list[0][:vol_files][:ereader].length).to eq(1)
      expect(return_list[0][:vol_files][:ereader].first.id).to eq('bpl-dev:3j334b41x')
    end

  end


end