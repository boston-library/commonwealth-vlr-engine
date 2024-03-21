# frozen_string_literal: true

require 'rails_helper'

describe CommonwealthVlrEngine::ImagesHelperBehavior do
  let(:blacklight_config) { CatalogController.blacklight_config }
  let(:item_pid) { 'bpl-dev:h702q6403' }
  let(:image_pid) { 'bpl-dev:h702q641c' }
  let(:collection_pid) { 'bpl-dev:h702q636h' }
  let(:document) { SolrDocument.find(item_pid) }
  let(:thumb_size) { '300' }

  before(:each) do
    allow(helper).to receive_messages(blacklight_config: blacklight_config)
  end

  describe '#collection_gallery_url' do
    it 'returns a thumbnail datastream if this is an OAI-harvested item' do
      expect(helper.collection_gallery_url({ exemplary_image_ssi: 'oai-dev:123456', hosting_status_ssi: 'harvested',
                                             exemplary_image_key_base_ss: 'metadata/oai-dev:123456' },
                                           thumb_size)).to include('oai-dev:123456/image_thumbnail_300.jpg')
    end

    it 'returns a IIIF URL if this is a repository item' do
      expect(
        helper.collection_gallery_url({ exemplary_image_ssi: image_pid }, thumb_size)
      ).to include("#{IIIF_SERVER['url']}#{image_pid}/square/#{thumb_size},/0/default.jpg")
    end

    it 'returns a region percentage if this is a newspaper collection' do
      expect(
        helper.collection_gallery_url({ exemplary_image_ssi: image_pid, destination_site_ssim: %w(newspapers) },
                                      thumb_size)
      ).to include("#{IIIF_SERVER['url']}#{image_pid}/pct:4,3,90,67/#{thumb_size},#{thumb_size}/0/default.jpg")
    end

    it 'returns the icon path if there is no exemplary_image_ssi value' do
      expect(helper.collection_gallery_url({}, thumb_size)).to include('dc_collection-icon')
    end
  end

  describe '#collection_icon_url' do
    it 'returns the right value' do
      expect(helper.collection_icon_url).to include('dc_collection-icon')
    end
  end

  describe '#index_relation_base_icon' do
    let(:coll_doc) { SolrDocument.find(collection_pid) }

    before(:each) do
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
      expect(helper.institution_icon_path).to include('dc_institution-icon')
    end
  end

  describe 'thumbnail creation helpers' do
    describe '#create_thumb_img_element' do
      it 'returns an image tag with the thumbnail image' do
        expect(helper.create_thumb_img_element(document).match(/\A<img[\s\S]+\/>\z/)).to be_truthy
        expect(helper.create_thumb_img_element(document)).to include("src=\"#{ASSET_STORE['url']}/derivatives/images/#{image_pid}/image_thumbnail_300.jpg")
      end
    end

    describe '#thumbnail_url' do
      let(:document_to_hash) { document.to_h }

      it 'returns the datastream path if there is an exemplary_image_ssi value' do
        expect(helper.thumbnail_url(document)).to eq("#{ASSET_STORE['url']}/derivatives/images/#{image_pid}/image_thumbnail_300.jpg")
      end

      describe 'with no exemplary image' do
        before(:each) { document_to_hash.delete('exemplary_image_ssi') }

        it 'returns the proper icon if there is a type_of_resource_ssim value' do
          expect(helper.thumbnail_url(SolrDocument.new(document_to_hash))).to include('dc_image-icon')
        end

        describe 'with no type_of_resource_ssim value' do
          before(:each) do
            document_to_hash.delete('type_of_resource_ssim')
            document_to_hash[blacklight_config.index.display_type_field] = 'Collection'
          end

          it 'returns the collection icon' do
            expect(helper.thumbnail_url(SolrDocument.new(document_to_hash))).to include('dc_collection-icon')
          end
        end
      end

      describe 'flagged item' do
        before(:each) { document_to_hash[blacklight_config.flagged_field] = 'explicit' }

        it 'returns the icon rather than the exemplary image' do
          expect(helper.thumbnail_url(SolrDocument.new(document_to_hash))).to include('dc_image-icon')
        end
      end
    end
  end
end
