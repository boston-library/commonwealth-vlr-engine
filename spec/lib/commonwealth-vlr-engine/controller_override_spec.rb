require 'spec_helper'

describe CommonwealthVlrEngine::ControllerOverride do

  class ControllerOverrideTestClass < CatalogController
  end

  let (:mock_controller) { ControllerOverrideTestClass.new }
  let (:override_config) { mock_controller.blacklight_config }

  #let(:document) { Blacklight.default_index.search({:q => "id:\"bpl-dev:h702q6403\"", :rows => 1}).documents.first }
  #let(:image_files) { @obj.get_files(document.id)[:images] }
  #let(:image_id_suffix) { image_files.first.id.gsub(/\A[\w-]+:/,'/') }

  describe 'customized blacklight configuration' do

    describe 'index document actions' do

      it 'should remove the unwanted actions' do
        expect(override_config.index.document_actions[:bookmark]).to be_empty
      end

    end

    describe 'show document actions' do

      it 'should remove the unwanted actions' do
        expect(override_config.show.document_actions[:email]).to be_empty
        expect(override_config.show.document_actions[:bookmark]).to be_empty
      end

      it 'should add the desired actions' do
        expect(override_config.show.document_actions[:custom_email]).not_to be_empty
        expect(override_config.show.document_actions[:folder_items]).not_to be_empty
      end

    end

  end

 end