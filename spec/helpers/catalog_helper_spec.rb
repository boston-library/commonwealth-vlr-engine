# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CatalogHelper do
  let(:mock_controller) { CatalogController.new }
  let(:item_ark_id) { 'bpl-dev:h702q6403' }
  let(:image_ark_id) { 'bpl-dev:h702q641c' }
  let(:collection_ark_id) { 'bpl-dev:h702q636h' }
  let(:document) { SolrDocument.find(item_ark_id) }
  let(:files_hash) { mock_controller.get_files(item_ark_id) }
  let(:document_item_ark_id) { 'bpl-dev:z029pg62r' }
  let(:document_files_hash) { mock_controller.get_files(document_item_ark_id) }
  let(:audio_files_hash) { mock_controller.get_files('bpl-dev:5d86p086p') }
  let(:harvested_item_ark_id) { 'oai-dev:qv33s812k' }
  let(:harvested_item) { SolrDocument.find(harvested_item_ark_id) }

  before(:each) do
    without_partial_double_verification do
      allow(helper).to receive(:blacklight_config).and_return(mock_controller.blacklight_config)
    end
  end

  describe 'file helpers' do
    describe '#has_image_files?' do
      it 'returns true if the object has image files' do
        expect(helper.has_image_files?(files_hash)).to be_truthy
      end
    end

    describe '#image_file_pids' do
      let(:image_file_pids_result) { helper.image_file_pids(files_hash[:image]) }
      it 'returns an array of ImageFile pids' do
        expect(image_file_pids_result.length).to eq(2)
        expect(image_file_pids_result.first).to eq(image_ark_id)
      end
    end

    describe '#has_video_files?' do
      let(:files_hash) { mock_controller.get_files('bpl-dev:cj82k894f') }
      it 'returns true if the object has video files' do
        expect(helper.has_video_files?(files_hash)).to be_truthy
      end
    end

    describe '#has_audio_files?' do
      it 'returns true if the object has audio files' do
        expect(helper.has_audio_files?(audio_files_hash)).to be_truthy
      end
    end

    describe '#has_playable_audio?' do
      it 'returns true if the object has playable audio' do
        expect(helper.has_playable_audio?(audio_files_hash)).to be_truthy
      end
    end

    describe '#has_document_files?' do
      it 'returns true if the object has document files' do
        expect(helper.has_document_files?(document_files_hash)).to be_truthy
      end
    end

    describe '#has_ereader_files?' do
      let(:files_hash) { mock_controller.get_files('bpl-dev:3j334603p') }

      it 'returns true if the object has E-reader files' do
        expect(helper.has_ereader_files?(files_hash)).to be_truthy
      end
    end
  end

  describe 'searchable text and uv methods' do
    let(:item_ark_id) { 'bpl-dev:7s75dn48d' }
    # let(:fulltext_document) { SolrDocument.find('bpl-dev:7s75dn48d') }

    describe '#has_searchable_text?' do
      it 'returns true if the object has searchable text' do
        expect(helper.has_searchable_text?(document)).to be_truthy
      end
    end

    describe '#include_uv?' do
      it 'returns true if the universal viewer should be rendered' do
        expect(helper.include_uv?(document, files_hash)).to be_truthy
      end
    end
  end

  describe 'collection link helpers' do
    let(:doc_with_two_cols) { SolrDocument.find('bpl-dev:g445cd14k') }

    describe '#index_collection_link' do
      describe 'for an item with one collection affiliation' do
        it 'renders the collection link' do
          expect(helper.index_collection_link({ document: document })).to include('<a href="/collections/' + collection_ark_id)
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

  describe '#index_institution_link' do
    it 'renders the institution link' do
      expect(helper.index_institution_link({ value: [document[:institution_name_ssi]],
                                             document: document })).to include('<a href="/institutions/' + document[:institution_ark_id_ssi])
    end
  end

  describe 'title helpers' do
    describe '#show_html_title' do
      let(:newspaper_issue_document) { SolrDocument.find('bpl-dev:z029pg62r') }

      it 'renders the full title with parts' do
        expect(helper.show_html_title({ document: newspaper_issue_document })).to eq 'Raivaaja. February 9, 1905 = Pioneer'
      end
    end

    describe '#index_title' do
      it 'returns the title for the catalog#index view' do
        expect(helper.index_title({ document: document })).to eq('Beauregard')
      end
    end

    describe '#index_title_length' do
      it 'returns the default length if no params[:view] is present' do
        expect(helper.index_title_length).to eq(130)
      end
    end
  end

  describe '#index_abstract' do
    let(:document) { SolrDocument.find('bpl-dev:000000000') }

    it 'returns the truncated abstract for the catalog#index view' do
      expect(helper.index_abstract({ value: [document['abstract_tsi']],
                                     document: document })).to include('read-more-link')
    end
  end

  describe '#harvested_object?' do
    it 'returns true for harvested items' do
      expect(helper.harvested_object?(harvested_item)).to be_truthy
    end
  end

  describe '#iiif_manifest_url' do
    it 'returns the iiif manifest url' do
      expect(helper.iiif_manifest_url(document)).to include('/manifest')
    end
  end
end
