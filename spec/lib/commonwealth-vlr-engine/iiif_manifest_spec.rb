require 'spec_helper'

describe CommonwealthVlrEngine::IiifManifest do

  include Blacklight::SearchHelper

  class IiifManifestTestClass < IiifManifestController
  end

  let(:document) { Blacklight.default_index.search({:q => "id:\"bpl-dev:h702q6403\"", :rows => 1}).documents.first }
  let(:image_files) { ['bpl-dev:h702q641c', 'bpl-dev:h702q642n'] }
  let(:image_id_suffix) { image_files.first.gsub(/\A[\w-]+:/,'/') }

  before { @obj = IiifManifestTestClass.new }

  describe 'create_iiif_manifest' do

    before { @manifest = @obj.create_iiif_manifest(document, image_files) }

    it 'should create an instance of IIIF::Presentation::Manifest' do
      expect(@manifest).not_to be_nil
      expect(@manifest.class).to eq(IIIF::Presentation::Manifest)
    end

    it 'should have metadata, sequences, canvases, images, and resources' do
      expect(@manifest.metadata.empty?).not_to be_truthy
      expect(@manifest.sequences.empty?).not_to be_truthy
      expect(@manifest.sequences[0].canvases.empty?).not_to be_truthy
      expect(@manifest.sequences[0].canvases[0].images.empty?).not_to be_truthy
      expect(@manifest.sequences[0].canvases[0].images[0].resource).not_to be_nil
    end

    it 'should have the right id' do
      expect(@manifest['@id']).to eq("#{document[:identifier_uri_ss]}/manifest")
    end

  end

  describe 'canvas_from_id' do

    before { @canvas = @obj.canvas_from_id(image_files.first, 'image1', document) }

    it 'should create an instance of IIIF::Presentation::Canvas' do
      expect(@canvas).not_to be_nil
      expect(@canvas.class).to eq(IIIF::Presentation::Canvas)
    end

    it 'should have images and resources' do
      expect(@canvas.images.empty?).not_to be_truthy
      expect(@canvas.images[0].resource).not_to be_nil
    end

    it 'should have the right id' do
      expect(@canvas['@id']).to eq("#{document[:identifier_uri_ss]}/canvas#{image_id_suffix}")
    end

  end

  describe 'image_annotation_from_image_id' do

    before { @annotation = @obj.image_annotation_from_image_id(image_files.first, document) }

    it 'should create an instance of IIIF::Presentation::Annotation' do
      expect(@annotation).not_to be_nil
      expect(@annotation.class).to eq(IIIF::Presentation::Annotation)
    end

    it 'should have a resource' do
      expect(@annotation.resource).not_to be_nil
    end

    it 'should have the right id' do
      expect(@annotation['@id']).to eq("#{document[:identifier_uri_ss]}/annotation#{image_id_suffix}")
    end

  end

  describe 'image_resource_from_image_id' do

    before { @image_resource = @obj.image_resource_from_image_id(image_files.first, document) }

    it 'should create an instance of IIIF::Presentation::ImageResource' do
      expect(@image_resource).not_to be_nil
      expect(@image_resource.class).to eq(IIIF::Presentation::ImageResource)
    end

    it 'should represent an image' do
      expect(@image_resource.format).to eq('image/jpeg')
      expect(@image_resource.width).not_to be_nil
    end

    it 'should have the right id' do
      expect(@image_resource['@id']).to eq(document[:identifier_uri_ss].gsub(/\/[\w]+\z/, image_id_suffix) + "/large_image")
    end

  end

  describe 'manifest_metadata' do

    before { @manifest_metadata = @obj.manifest_metadata(document) }

    it 'should create a hash of metadata' do
      expect(@manifest_metadata.empty?).to be_falsey
    end

    it 'should have a bunch of metadata about the item' do
      expect(@manifest_metadata.find { |field| field[:label] == I18n.t('blacklight.metadata_display.fields.title') }[:value]).to eq(document[IiifManifestTestClass.blacklight_config.index.title_field.to_sym])
      expect(@manifest_metadata.find { |field| field[:label] == I18n.t('blacklight.metadata_display.fields.collection') }[:value]).to eq(document[:related_item_host_ssim].first)
    end

  end

end