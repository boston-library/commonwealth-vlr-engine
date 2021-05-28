# frozen_string_literal: true

require 'rails_helper'

describe CommonwealthVlrEngine::CatalogHelperBehavior do
  let(:blacklight_config) { CatalogController.blacklight_config }
  let(:catalog_helper_test_class) { CatalogController.new }
  let(:item_pid) { 'bpl-dev:h702q6403' }
  let(:image_pid) { 'bpl-dev:h702q641c' }
  let(:collection_pid) { 'bpl-dev:h702q636h' }
  let(:document) { SolrDocument.find(item_pid) }
  let(:files_hash) { catalog_helper_test_class.get_files(item_pid) }

  before(:each) do
    allow(helper).to receive_messages(blacklight_config: blacklight_config)
  end

  describe 'file helpers' do
    describe '#has_image_files?' do
      it 'returns true' do
        expect(helper.has_image_files?(files_hash)).to be_truthy
      end
    end

    describe '#image_file_pids' do
      let(:image_file_pids_result) { helper.image_file_pids(files_hash[:image]) }
      it 'returns an array of ImageFile pids' do
        expect(image_file_pids_result.length).to eq(2)
        expect(image_file_pids_result.first).to eq(image_pid)
      end
    end

    describe '#has_video_files?' do
      it 'returns true' do
        files_hash[:video] = [SolrDocument.new] # TODO: create a video file fixture in sample solr docs
        expect(helper.has_video_files?(files_hash)).to be_truthy
      end
    end
  end

  describe 'collection link helpers' do
    let(:doc_with_two_cols) { SolrDocument.find('bpl-dev:g445cd14k') }

    describe '#index_collection_link' do
      describe 'for an item with one collection affiliation' do
        it 'renders the collection link' do
          expect(helper.index_collection_link({ document: document })).to include('<a href="/collections/' + collection_pid)
        end
      end

      describe 'for an item with two collection affiliations' do
        it 'renders two collection links' do
          expect(helper.index_collection_link({ document: doc_with_two_cols }).scan(/<a href="\/collections/).length).to eq(2)
        end
      end
    end

    describe '#setup_collection_links' do
      describe 'for an item with one collection affiliation' do
        it 'returns a single link' do
          expect(helper.setup_collection_links(document).length).to eq(1)
        end
      end

      describe 'for an item with two collection affiliations' do
        it 'renders two collection links' do
          expect(helper.setup_collection_links(doc_with_two_cols).length).to eq(2)
        end
      end
    end
  end

  describe '#index_title_length' do
    it 'returns the default length if no params[:view] is present' do
      expect(helper.index_title_length).to eq(130)
    end
  end

  describe '#insert_opengraph_markup' do
    before(:each) do
      assign(:document, document)
      assign(:object_files, files_hash)
      allow(helper).to receive(:controller_name).and_return('catalog')
      allow(helper).to receive(:action_name).and_return('show')
      helper.insert_opengraph_markup
    end

    it 'renders the catalog/opengraph partial' do
      expect(helper.content_for(:head)).to include '<meta property="og:title" content="Beauregard" />'
    end
  end

  describe '#link_to_az_value' do
    it 'creates a link with the correct letter, field, and path' do
      expect(helper.link_to_az_value('X', 'some_field_name', 'collections_path')).to include('collections?q=some_field_name%3AX%2A')
    end
  end

  describe '#render_item_breadcrumb' do
    it 'renders the output of #setup_collection_links()' do
      expect(helper.render_item_breadcrumb(document)).to include('<a href="/collections/' + collection_pid)
    end
  end

  describe '#render_mlt_search_link' do
    it 'renders a search link with the mlt_id param' do
      expect(helper.render_mlt_search_link(document).match(/href=[a-z"\\\/?]*mlt_id=[a-z0-9]+/)).to be_truthy
    end
  end

  describe '#render_search_to_page_title' do
    it 'returns the correct string for the page title' do
      expect(helper.render_search_to_page_title({ mlt_id: item_pid })).to include(I18n.t('blacklight.more_like_this.constraint_label'))
    end
  end
end
