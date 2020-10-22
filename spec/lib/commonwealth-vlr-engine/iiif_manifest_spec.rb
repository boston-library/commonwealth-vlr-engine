# frozen_string_literal: true

require 'rails_helper'

describe CommonwealthVlrEngine::IiifManifest, :vcr do
  let(:mock_controller) { IiifManifestController.new }
  let(:document) { SolrDocument.find('bpl-dev:h702q6403') }
  let(:image_files) { mock_controller.get_files(document.id)[:images] }
  let(:image_id_suffix) { image_files.first.id.gsub(/\A[\w-]+:/, '/') }

  describe 'create_iiif_manifest' do
    let(:manifest) { mock_controller.create_iiif_manifest(document, image_files) }

    it 'creates an instance of IIIF::Presentation::Manifest' do
      expect(manifest).not_to be_nil
      expect(manifest.class).to eq(IIIF::Presentation::Manifest)
    end

    it 'has metadata, sequences, canvases, images, and resources' do
      expect(manifest.metadata).not_to be_empty
      expect(manifest.sequences).not_to be_empty
      expect(manifest.sequences[0].canvases).not_to be_empty
      expect(manifest.sequences[0].canvases[0].images).not_to be_empty
      expect(manifest.sequences[0].canvases[0].images[0].resource).not_to be_nil
    end

    it 'has the right id' do
      expect(manifest['@id']).to eq("#{document[:identifier_uri_ss]}/manifest")
    end
  end

  describe 'canvas_from_id' do
    let(:canvas) { mock_controller.canvas_from_id(image_files.first.id, 'image1', document) }

    it 'creates an instance of IIIF::Presentation::Canvas' do
      expect(canvas.class).to eq(IIIF::Presentation::Canvas)
    end

    it 'has images and resources' do
      expect(canvas.images).not_to be_empty
      expect(canvas.images[0].resource).not_to be_nil
    end

    it 'has the right id' do
      expect(canvas['@id']).to eq("#{document[:identifier_uri_ss]}/canvas#{image_id_suffix}")
    end
  end

  describe 'image_annotation_from_image_id' do
    let(:annotation) { mock_controller.image_annotation_from_image_id(image_files.first.id, document) }

    it 'creates an instance of IIIF::Presentation::Annotation' do
      expect(annotation).not_to be_nil
      expect(annotation.class).to eq(IIIF::Presentation::Annotation)
    end

    it 'has a resource' do
      expect(annotation.resource).not_to be_nil
    end

    it 'has the right id' do
      expect(annotation['@id']).to eq("#{document[:identifier_uri_ss]}/annotation#{image_id_suffix}")
    end
  end

  describe 'image_resource_from_image_id' do
    let(:image_resource) do
      mock_controller.image_resource_from_image_id(image_files.first.id, document)
    end

    it 'creates an instance of IIIF::Presentation::ImageResource' do
      expect(image_resource).not_to be_nil
      expect(image_resource.class).to eq(IIIF::Presentation::ImageResource)
    end

    it 'should represent an image' do
      expect(image_resource.format).to eq('image/jpeg')
      expect(image_resource.width).not_to be_nil
    end

    it 'has the right id' do
      expect(image_resource['@id']).to eq(document[:identifier_uri_ss].gsub(/\/[\w]+\z/, image_id_suffix) + '/large_image')
    end
  end

  describe 'collection_for_manifests' do
    let(:manifest_docs) { [SolrDocument.find('bpl-dev:rf55z9490'), SolrDocument.find('bpl-dev:7s75dn48d')] }
    let(:collection) { mock_controller.collection_for_manifests(document, manifest_docs) }

    it 'creates an instance of IIIF::Presentation::Collection' do
      expect(collection).not_to be_nil
      expect(collection.class).to eq(IIIF::Presentation::Collection)
    end

    it 'has contain a list of manifests' do
      expect(collection.manifests.length).to eq(2)
      expect(collection.manifests.first['@id']).to include('rf55z9490')
    end

    it 'has the right id' do
      expect(collection['@id']).to eq(document[:identifier_uri_ss].gsub(/\/[\w]+\z/, '/collection\\0'))
    end
  end

  describe 'manifest_metadata' do
    let(:manifest_metadata) { mock_controller.manifest_metadata(document) }

    it 'creates a hash of metadata' do
      expect(manifest_metadata).not_to be_empty
    end

    it 'has a bunch of metadata about the item' do
      expect(manifest_metadata.find { |field| field[:label] == I18n.t('blacklight.metadata_display.fields.title') }[:value]).to eq(
        document[mock_controller.blacklight_config.index.title_field.to_sym]
      )
      expect(manifest_metadata.find { |field| field[:label] == I18n.t('blacklight.metadata_display.fields.collection') }[:value]).to eq(
        document[:related_item_host_ssim].first
      )
    end
  end

  describe 'manifest_attribution' do
    let(:manifest_attribution) { mock_controller.manifest_attribution(document) }

    it 'creates an attribution string' do
      expect(manifest_attribution).to include('No known copyright restrictions')
    end
  end

  describe 'label_for_canvas' do
    let(:label_for_canvas) { mock_controller.label_for_canvas(image_files.first, 0) }

    it 'returns the correct label' do
      expect(label_for_canvas).to eq('Front')
    end
  end
end
