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

    it 'has an :images key with a hash of Bplmodel::ImageFile SolrDocs as the value' do
      expect(return_hash[:images].length).to eq(2)
      expect(return_hash[:images][0].class).to eq(SolrDocument)
      expect(return_hash[:images][0]['active_fedora_model_ssi']).to eq('Bplmodels::ImageFile')
    end

    it 'has the right ImageFile objects for the item' do
      expect(return_hash[:images].to_s).to include(image1_pid)
    end

    # TODO: specs for each file type, and associated get_* methods
    it 'has keys for other file types' do
      %i(documents audio ereader video generic).each do |k|
        expect(return_hash[k]).not_to be_nil
      end
    end

    describe 'sort_files' do
      it 'has the images in the right order' do
        expect(return_hash[:images][0]['id']).to eq(image1_pid)
        expect(return_hash[:images][1]['id']).to eq(image2_pid)
      end
    end
  end

  describe 'get_image_files' do
    let(:return_list) { mock_controller.get_image_files(item_pid) }

    it 'creates an array with the ImageFile objects' do
      expect(return_list.length).to eq(2)
      expect(return_list[0]['active_fedora_model_ssi']).to eq('Bplmodels::ImageFile')
    end

    it 'has the right ImageFile objects for the item, in the right order' do
      expect(return_list[0]['id']).to eq(image1_pid)
    end
  end

  describe 'get_first_image_file' do
    let(:response) { mock_controller.get_first_image_file(item_pid) }

    it 'returns the first ImageFile object' do
      expect(response['id']).to eq(image1_pid)
    end
  end

  describe 'get_next_image_file' do
    let(:response) { mock_controller.get_next_image_file(image1_pid) }

    it 'returns the next ImageFile object' do
      expect(response['id']).to eq(image2_pid)
    end
  end

  describe 'get_prev_image_file' do
    let(:response) { mock_controller.get_prev_image_file(image2_pid) }

    it 'returns the next ImageFile object' do
      expect(response['id']).to eq(image1_pid)
    end
  end

  describe 'get_file_parent_object' do
    let(:response) { mock_controller.get_file_parent_object(image2_pid) }

    it 'returns the parent object' do
      expect(response['id']).to eq(item_pid)
    end
  end
end
