require 'rails_helper'

describe CommonwealthVlrEngine::ImagesHelperBehavior do
  let(:blacklight_config) { CatalogController.blacklight_config }
  #let(:catalog_helper_test_class) { CatalogController.new }
  let(:item_pid) { 'bpl-dev:h702q6403' }
  let(:image_pid) { 'bpl-dev:h702q641c' }
  let(:collection_pid) { 'bpl-dev:h702q636h' }
  let(:document) { SolrDocument.find(item_pid) }
  #let(:files_hash) { catalog_helper_test_class.get_files(item_pid) }

  before(:each) do
    allow(helper).to receive_messages(blacklight_config: blacklight_config)
  end

  describe '#collection_gallery_url' do
    it 'returns a thumbnail datastream if this is an OAI-harvested item' do
      expect(helper.collection_gallery_url({exemplary_image_ssi: 'oai-dev:123456'}, '300')).to include('oai-dev:123456/datastreams/thumbnail300/content')
    end

    it 'returns a IIIF URL if this is a repository item' do
      expect(helper.collection_gallery_url({ exemplary_image_ssi: image_pid }, '300')).to include("#{IIIF_SERVER['url']}#{image_pid}/square/300,/0/default.jpg")
    end

    it 'returns the icon path if there is no exemplary_image_ssi value' do
      expect(helper.collection_gallery_url({}, '300')).to include('dc_collection-icon.png')
    end
  end

  describe '#collection_icon_path' do
    it 'returns the right value' do
      expect(helper.collection_icon_path).to include('dc_collection-icon.png')
    end
  end

  describe '#index_relation_base_icon' do
    let(:coll_doc) { SolrDocument.find(collection_pid) }

    before do
      allow(helper).to receive(:document_index_view_type).and_return('index')
      allow(helper).to receive(:controller_name).and_return('catalog')
    end

    it 'returns a collection icon' do
      expect(helper.index_relation_base_icon(coll_doc)).to include('dc_collection-icon')
      expect(helper.index_relation_base_icon(coll_doc)).to include('.png')
    end
  end

  describe '#index_slideshow_img_url' do
    it 'returns a IIIF image URL if there is an exemplary image' do
      expect(helper.index_slideshow_img_url(document)).to eq("#{IIIF_SERVER['url']}#{image_pid}/full/,500/0/default.jpg")
    end
  end

  describe '#institution_icon_path' do
    it 'returns the right value' do
      expect(helper.institution_icon_path).to include('dc_institution-icon.png')
    end
  end

  describe 'thumbnail creation helpers' do
    describe '#create_thumb_img_element' do
      it 'returns an image tag with the thumbnail image' do
        expect(helper.create_thumb_img_element(document).match(/\A<img[\s\S]+\/>\z/)).to be_truthy
        expect(helper.create_thumb_img_element(document)).to include("src=\"#{FEDORA_URL['url']}/objects/#{image_pid}/datastreams/thumbnail300/content")
      end
    end

    describe '#thumbnail_url' do
      let(:document_to_hash) { document.to_h }

      it 'returns the datastream path if there is an exemplary_image_ssi value' do
        expect(helper.thumbnail_url(document)).to eq("#{FEDORA_URL['url']}/objects/#{image_pid}/datastreams/thumbnail300/content")
      end

      describe 'with no exemplary image' do
        before { document_to_hash.delete('exemplary_image_ssi') }

        it 'returns the proper icon if there is a type_of_resource_ssim value' do
          expect(helper.thumbnail_url(SolrDocument.new(document_to_hash))).to include('dc_image-icon.png')
        end

        describe 'with no type_of_resource_ssim value' do
          before do
            document_to_hash.delete('type_of_resource_ssim')
            document_to_hash[blacklight_config.index.display_type_field] = 'Collection'
          end

          it 'returns the collection icon' do
            expect(helper.thumbnail_url(SolrDocument.new(document_to_hash))).to include('dc_collection-icon.png')
          end
        end
      end

      describe 'flagged item' do
        before { document_to_hash[blacklight_config.flagged_field] = true }

        it 'returns the icon rather than the exemplary image' do
          expect(helper.thumbnail_url(SolrDocument.new(document_to_hash))).to include('dc_image-icon.png')
        end
      end
    end
  end
end
