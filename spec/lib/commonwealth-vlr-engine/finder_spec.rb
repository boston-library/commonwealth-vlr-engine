# frozen_string_literal: true

require 'rails_helper'

describe CommonwealthVlrEngine::Finder do
  let(:mock_controller) { CatalogController.new }
  let(:item_pid) { 'bpl-dev:h702q6403' }
  let(:image1_pid) { 'bpl-dev:h702q641c' }
  let(:image2_pid) { 'bpl-dev:h702q642n' }

  describe 'get_files' do
    let(:return_hash) { mock_controller.get_files(item_pid) }

    it 'creates a hash with the file objects' do
      expect(return_hash.length).to eq(6)
    end

    it 'has an :images key with a hash of Curator::Filestreams::Image SolrDocs as the value' do
      expect(return_hash[:image].length).to eq(2)
      expect(return_hash[:image][0].class).to eq(SolrDocument)
      expect(return_hash[:image][0]['curator_model_ssi']).to eq('Curator::Filestreams::Image')
    end

    it 'has the right objects for the item' do
      expect(return_hash[:image].to_s).to include(image1_pid)
    end

    it 'has the images in the right order' do
      expect(return_hash[:image][0]['id']).to eq(image1_pid)
      expect(return_hash[:image][1]['id']).to eq(image2_pid)
    end

    # TODO: specs for each file type (need sample docs for all file types)
    it 'has keys for other file types' do
      %i(document audio ereader video generic).each do |k|
        expect(return_hash[k]).not_to be_nil
      end
    end
  end

  describe 'get_image_files' do
    let(:return_list) { mock_controller.get_image_files(item_pid) }

    it 'creates an array with the ImageFile objects' do
      expect(return_list.length).to eq(2)
      expect(return_list[0]['curator_model_ssi']).to eq('Curator::Filestreams::Image')
    end

    it 'has the right objects for the item, in the right order' do
      expect(return_list[0]['id']).to eq(image1_pid)
    end
  end
end
