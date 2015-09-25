require 'spec_helper'

describe CatalogHelper do

  include Blacklight::SearchHelper
  #include CommonwealthVlrEngine::Finder

  #class CatalogHelperTestClass < CatalogController
  #end

  #let(:test_controller) { CatalogHelperTestClass.new }

  class FinderTestClass < CatalogController
    cattr_accessor :blacklight_config, :controller_name

    include Blacklight::SearchHelper
    include CommonwealthVlrEngine::Finder

    def initialize blacklight_config
      self.blacklight_config = blacklight_config
      self.controller_name = 'catalog'
    end

  end

  let(:blacklight_config) { CatalogController.blacklight_config }

  let(:finder_test_class) { FinderTestClass.new blacklight_config }

#  before do
#    @obj = FinderTestClass.new blacklight_config
#    @item_pid = 'bpl-dev:h702q6403'
#    @image1_pid = 'bpl-dev:h702q641c'
#    @image2_pid = 'bpl-dev:h702q642n'
#  end

  before(:each) do
    allow(helper).to receive_messages(blacklight_config: blacklight_config)

#    @fake_controller = RenderConstraintsOverrideTestClass.new
#    @fake_controller.extend(CommonwealthVlrEngine::RenderConstraintsOverride)
#    @fake_controller.params = { mlt_id: 'bpl-dev:h702q6403' }
  end

  let(:item_pid) { 'bpl-dev:h702q6403' }
  let(:image_pid) { 'bpl-dev:h702q641c' }
  let(:document) { Blacklight.default_index.search({:q => "id:\"#{item_pid}\"", :rows => 1}).documents.first }
  let(:files_hash) { finder_test_class.get_files(item_pid) }

  describe 'Creative Commons license helpers' do

    let(:license) { 'This work is licensed for use under a Creative Commons Attribution Non-Commercial No Derivatives License (CC BY-NC-ND).' }
    let (:cc_url) { 'http://creativecommons.org/licenses/by-nc-nd/3.0' }

    describe '#cc_terms_code' do
      it 'should return the right value' do
        expect(helper.cc_terms_code(license)).to eq('by-nc-nd')
      end
    end

    describe '#cc_url' do
      it 'should return the right value' do
        expect(helper.cc_url(license)).to eq(cc_url)
      end
    end

    describe '#render_cc_license' do
      it 'should render the CC link and image' do
        expect(helper.render_cc_license(license)).to include('href="' + cc_url)
        expect(helper.render_cc_license(license)).to include('src="//i.creativecommons.org/l/')
      end
    end

  end

  describe '#collection_gallery_url' do

    it 'should return a thumbnail datastream if this is an OAI-harvested item' do
      expect(helper.collection_gallery_url({exemplary_image_ssi: 'oai-dev:123456'},'300')).to include('oai-dev:123456/datastreams/thumbnail300/content')
    end

    it 'should return a IIIF URL if this is a repository item' do
      expect(helper.collection_gallery_url({exemplary_image_ssi: image_pid},'300')).to include("#{IIIF_SERVER['url']}#{image_pid}/0,476,1496,1496/300,300/0/default.jpg")
    end

    it 'should return the icon path if there is no exemplary_image_ssi value' do
      expect(helper.collection_gallery_url({},'300')).to include('dc_collection-icon.png')
    end

  end

  describe '#collection_icon_path' do
    it 'should return the right value' do
      expect(helper.collection_icon_path).to include('dc_collection-icon.png')
    end
  end

  describe 'download_links helpers' do

    before do
      # copy :images to :documents, since we don't have any non-image items to test with at the moment
      files_hash[:documents] = files_hash[:images]
      @download_links = helper.create_download_links(files_hash, 'link_class')
    end

    describe '#create_download_links' do

      it 'should return an array of links' do
        expect(@download_links.length).to eq(2)
        expect(@download_links.first.match(/\A<a[a-z =\\"_]*href=/)).to be_truthy
      end

      it 'should link to the productionMaster datastream' do
        expect(@download_links.first).to include("href=\"#{FEDORA_URL['url']}/objects/#{image_pid}/datastreams/productionMaster/content")
      end

    end

    describe '#has_downloadable_files?' do
      it 'should return true if there are documents, audio, or generic files' do
        expect(helper.has_downloadable_files?(files_hash)).to be_truthy
      end
    end

  end

  describe '#has_image_files?' do
    it 'should return an array of ImageFile pids' do
      expect(helper.has_image_files?(files_hash).length).to eq(2)
      expect(helper.has_image_files?(files_hash).first).to eq(image_pid)
    end
  end

  describe 'collection link helpers' do

    let(:doc_with_two_cols) { Blacklight.default_index.search({:q => 'id:"bpl-dev:g445cd14k"', :rows => 1}).documents.first }

    describe '#index_collection_link' do

      describe 'for an item with one collection affiliation' do
        it 'should render the collection link' do
          expect(helper.index_collection_link({document: document})).to include('<a href="/collections/bpl-dev:h702q636h')
        end
      end

      describe 'for an item with two collection affiliations' do
        it 'should render two collection links' do
          expect(helper.index_collection_link({document: doc_with_two_cols}).scan(/<a href="\/collections/).length).to eq(2)
        end
      end

    end

    describe '#setup_collection_links' do

      describe 'for an item with one collection affiliation' do
        it 'should return a single link' do
          expect(helper.setup_collection_links(document).length).to eq(1)
        end
      end

      describe 'for an item with two collection affiliations' do
        it 'should render two collection links' do
          expect(helper.setup_collection_links(doc_with_two_cols).length).to eq(2)
        end
      end

    end

  end

  describe '#index_relation_base_icon' do

    let(:coll_doc) { Blacklight.default_index.search({:q => 'id:"bpl-dev:h702q636h"', :rows => 1}).documents.first }

    before do
      allow(helper).to receive(:document_index_view_type).and_return('index')
      allow(helper).to receive_messages(controller: finder_test_class)
    end

    it 'should return a collection icon' do
      expect(helper.index_relation_base_icon(coll_doc)).to include('dc_collection-icon.png')
    end

  end

  describe '#index_slideshow_img_url' do
    it 'should return a IIIF image URL if there is an exemplary image' do
      expect(helper.index_slideshow_img_url(document)).to eq("#{IIIF_SERVER['url']}#{image_pid}/full/,500/0/default.jpg")
    end
  end

  describe '#index_title_length' do
    it 'should return the default length if no params[:view] is present' do
      expect(helper.index_title_length).to eq(130)
    end
  end

  describe '#institution_icon_path' do
    it 'should return the right value' do
      expect(helper.institution_icon_path).to include('dc_institution-icon.png')
    end
  end

  describe '#normalize_date' do
    it 'should return normalized date values' do
      expect(helper.normalize_date('2015-07-05')).to eq('July 5, 2015')
      expect(helper.normalize_date('2015-07')).to eq('July 2015')
    end
  end

  describe '#render_hiergo_subject' do

    before { @rendered_hiergeo = helper.render_hiergo_subject(document[:subject_hiergeo_geojson_ssm].first, ' | ') }

    it 'should return a set of links to geographic subjects' do
      expect(@rendered_hiergeo.scan(/href=\"\/search\?f%5Bsubject_geographic_ssim/).length).to eq(3)
    end

    it 'should join the links using the separator' do
      expect(@rendered_hiergeo.scan(/<span> \| <\/span>/).length).to eq(2)
    end

    it 'should add the county label to the county value' do
      expect(@rendered_hiergeo).to include(' (county)')
    end

  end

  describe 'thumbnail creation helpers' do

    describe '#create_thumb_img_element' do
      it 'should return an image tag with the thumbnail image' do
        expect(helper.create_thumb_img_element(document).match(/\A<img[\s\S]+\/>\z/)).to be_truthy
        expect(helper.create_thumb_img_element(document)).to include("src=\"#{FEDORA_URL['url']}/objects/#{image_pid}/datastreams/thumbnail300/content")
      end
    end

    describe '#thumbnail_url' do

      it 'should return the datastream path if there is an exemplary_image_ssi value' do
        expect(helper.thumbnail_url(document)).to eq("#{FEDORA_URL['url']}/objects/#{image_pid}/datastreams/thumbnail300/content")
      end

      describe 'with no exemplary image' do

        before { document.delete(:exemplary_image_ssi) }

        it 'should return the proper icon if there is a type_of_resource_ssim value' do
          expect(helper.thumbnail_url(document)).to include('dc_image-icon.png')
        end

        describe 'with no type_of_resource_ssim value' do

          before do
            document.delete(:type_of_resource_ssim)
            document[blacklight_config.index.display_type_field.to_sym] = 'Collection'
          end

          it 'should return the collection icon' do
            expect(helper.thumbnail_url(document)).to include('dc_collection-icon.png')
          end

        end

      end

      describe 'flagged item' do

        before { document[blacklight_config.flagged_field.to_sym] = true }

        it 'should return the icon rather than the exemplary image' do
          expect(helper.thumbnail_url(document)).to include('dc_image-icon.png')
        end

      end

    end

  end

end