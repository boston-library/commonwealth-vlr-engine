require 'spec_helper'

describe CatalogHelper do

  include Blacklight::SearchHelper

  class CatalogHelperTestClass < CatalogController
    cattr_accessor :blacklight_config

    include Blacklight::SearchHelper
    include CommonwealthVlrEngine::Finder

    def initialize blacklight_config
      self.blacklight_config = blacklight_config
    end

  end

  let(:blacklight_config) { CatalogController.blacklight_config }
  let(:catalog_helper_test_class) { CatalogHelperTestClass.new blacklight_config }
  let(:item_pid) { 'bpl-dev:h702q6403' }
  let(:image_pid) { 'bpl-dev:h702q641c' }
  let (:collection_pid) { 'bpl-dev:h702q636h' }
  let(:document) { Blacklight.default_index.search({:q => "id:\"#{item_pid}\"", :rows => 1}).documents.first }
  let(:files_hash) { catalog_helper_test_class.get_files(item_pid) }

  before(:each) do
    allow(helper).to receive_messages(blacklight_config: blacklight_config)
  end

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

  describe 'image file helpers' do

    describe '#has_image_files?' do
      it 'should return true' do
        expect(helper.has_image_files?(files_hash)).to be_truthy
      end
    end

    describe '#image_file_pids' do
      let (:image_file_pids_result) { helper.image_file_pids(files_hash[:images]) }
      it 'should return an array of ImageFile pids' do
        expect(image_file_pids_result.length).to eq(2)
        expect(image_file_pids_result.first).to eq(image_pid)
      end
    end

  end

  describe '#has_volumes?' do

    let (:book_with_volumes_pid) { 'bpl-dev:3j334b469' }
    let(:series_document) { Blacklight.default_index.search({:q => "id:\"#{book_with_volumes_pid}\"", :rows => 1}).documents.first }
    let(:has_volumes_output) { catalog_helper_test_class.has_volumes?(series_document) }

    it 'should return an array of hashes with the Volume documents and files' do
      expect(has_volumes_output.length).to eq(2)
      expect(has_volumes_output[0][:vol_doc].class).to eq(SolrDocument)
      expect(has_volumes_output[0][:vol_files][:ereader]).to_not be_empty
    end

  end

  describe 'collection link helpers' do

    let(:doc_with_two_cols) { Blacklight.default_index.search({:q => 'id:"bpl-dev:g445cd14k"', :rows => 1}).documents.first }

    describe '#index_collection_link' do

      describe 'for an item with one collection affiliation' do
        it 'should render the collection link' do
          expect(helper.index_collection_link({document: document})).to include('<a href="/collections/' + collection_pid)
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

    let(:coll_doc) { Blacklight.default_index.search({:q => 'id:"' + collection_pid + '"', :rows => 1}).documents.first }

    before do
      allow(helper).to receive(:document_index_view_type).and_return('index')
      allow(helper).to receive(:controller_name).and_return('catalog')
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

  describe '#link_to_az_value' do
    it 'should create a link with the correct letter, field, and path' do
      expect(helper.link_to_az_value('X', 'some_field_name', 'collections_path')).to include('collections?q=some_field_name%3AX%2A')
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

  describe '#render_item_breadcrumb' do
    it 'should render the output of #setup_collection_links()' do
      expect(helper.render_item_breadcrumb(document)).to include('<a href="/collections/' + collection_pid)
    end
  end

  describe 'title helpers' do

    describe '#render_full_title' do
      let(:doc_with_subtitle) { Blacklight.default_index.search({:q => 'id:"bpl-dev:00000003t"', :rows => 1}).documents.first }
      it 'should render the title correctly' do
        expect(helper.render_full_title(doc_with_subtitle)).to include('Massachusetts : based')
      end
    end

    describe '#render_main_title' do
      it 'should render the title correctly' do
        expect(helper.render_main_title({title_info_primary_tsi: 'Foo', title_info_partnum_tsi: 'vol.2'})).to eq('Foo. vol.2')
      end
    end

    describe '#render_volume_title' do
      it 'should return the correct value' do
        expect(helper.render_volume_title({title_info_partnum_tsi: 'vol.2', title_info_partname_tsi: 'Foo'})).to eq('Vol.2: Foo')
      end
    end

  end

  describe '#render_mlt_search_link' do
    it 'should render a search link with the mlt_id param' do
      expect(helper.render_mlt_search_link(document).match(/href=[a-z"\\\/?]*mlt_id=[a-z0-9]+/)).to be_truthy
    end
  end

  describe '#render_mods_dates' do
    it 'should return an array of date values' do
      expect(helper.render_mods_dates(document).first).not_to be_nil
    end
  end

  describe '#render_mods_date' do

    describe 'date with start, end, and qualifier' do
      it 'should return the correct date value' do
        expect(helper.render_mods_date('1984', '1985', 'approximate')).to eq('[ca. 1984–1985]')
      end
    end

    describe 'copyright date' do
      it 'should return the correct date value' do
        expect(helper.render_mods_date('1984', nil, nil, 'copyrightDate')).to eq('(c) 1984')
      end
    end

  end

  describe '#render_search_to_page_title' do
    before { @page_title = helper.render_search_to_page_title({mlt_id: item_pid}) }
    it 'should return the correct string for the page title' do
      expect(@page_title).to include(I18n.t('blacklight.more_like_this.constraint_label'))
    end
  end

  describe '#render_mods_xml_record' do
    before { @mods_xml_doc = helper.render_mods_xml_record(item_pid) }
    it 'should return the XML document for the MODS record' do
      expect(@mods_xml_doc.class).to eq(REXML::Document)
      expect(@mods_xml_doc.to_s).to include('<mods:title>Beauregard</mods:title>')
    end
  end

  describe '#return_oai_inst_name' do
    it 'should return the institution name' do
      expect(helper.return_oai_inst_name(document)).to eq('Boston Public Library')
    end
  end

  describe '#setup_names_roles' do

    let(:doc_with_names) { Blacklight.default_index.search({:q => 'id:"bpl-dev:df65v788h"', :rows => 1}).documents.first }
    before { @names, @roles = helper.setup_names_roles(doc_with_names) }

    it 'should return two arrays of values' do
      expect(@names.length).to eq(2)
      expect(@roles.first).not_to be_nil
    end

    it 'should have the correct values in the arrays' do
      expect(@names[0]).to include('Niccolo')
      expect(@roles[0]).to eq('Cartographer')
      expect(@names[1]).to include('Antonio')
      expect(@roles[1]).to eq('Creator')
    end

  end

  describe '#should_autofocus_on_search_box?' do
    it 'should return false' do
      expect(helper.should_autofocus_on_search_box?).to be_falsey
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

      let(:document_to_hash) { document.to_h }

      it 'should return the datastream path if there is an exemplary_image_ssi value' do
        expect(helper.thumbnail_url(document)).to eq("#{FEDORA_URL['url']}/objects/#{image_pid}/datastreams/thumbnail300/content")
      end

      describe 'with no exemplary image' do

        before { document_to_hash.delete('exemplary_image_ssi') }

        it 'should return the proper icon if there is a type_of_resource_ssim value' do
          expect(helper.thumbnail_url(SolrDocument.new(document_to_hash))).to include('dc_image-icon.png')
        end

        describe 'with no type_of_resource_ssim value' do

          before do
            document_to_hash.delete('type_of_resource_ssim')
            document_to_hash[blacklight_config.index.display_type_field] = 'Collection'
          end

          it 'should return the collection icon' do
            expect(helper.thumbnail_url(SolrDocument.new(document_to_hash))).to include('dc_collection-icon.png')
          end

        end

      end

      describe 'flagged item' do

        before { document_to_hash[blacklight_config.flagged_field] = true }

        it 'should return the icon rather than the exemplary image' do
          expect(helper.thumbnail_url(SolrDocument.new(document_to_hash))).to include('dc_image-icon.png')
        end

      end

    end

  end

end