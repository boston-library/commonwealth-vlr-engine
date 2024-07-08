# frozen_string_literal: true

require 'rails_helper'

describe CommonwealthVlrEngine::ControllerOverride do
  let(:mock_controller) { CatalogController.new }
  let(:test_config) { mock_controller.blacklight_config }

  describe 'customized blacklight configuration' do
    describe 'facet_fields' do
      subject { test_config.facet_fields }

      # test a sampling of fields, just to make sure
      it 'has the expected facet fields' do
        expect(subject['subject_facet_ssim']).not_to be_falsey
        expect(subject['genre_basic_ssim'].class).to eq(Blacklight::Configuration::FacetField)
        expect(subject['collection_name_ssim'].label).to eq('Collection')
        expect(subject['name_facet_ssim'].include_in_request).to be_falsey
      end
    end

    describe 'index_fields' do
      subject { test_config.index_fields }

      it 'has the expected index fields' do
        expect(subject['name_facet_ssim']).not_to be_falsey
        expect(subject['genre_basic_ssim'].class).to eq(Blacklight::Configuration::IndexField)
        expect(subject['collection_name_ssim'].label).to eq('Collection')
        expect(subject['date_tsim'].helper_method).to eq(:index_date_value)
      end
    end

    describe 'search_fields' do
      it 'has the expected search fields' do
        %w(all_fields all_fields_ft title subject place creator).each do |field_name|
          expect(test_config.search_fields[field_name]).not_to be_falsey
          expect(test_config.search_fields[field_name].class).to eq(Blacklight::Configuration::SearchField)
        end
      end
    end

    describe 'sort_fields' do
      subject { test_config.sort_fields }

      it 'has the expected fields' do
        expect(subject.count).to eq 5
        expect(subject['score desc, title_info_primary_ssort asc']).not_to be_falsey
      end
    end

    describe 'thumbnail_method' do
      it 'sets the thumbnail_method' do
        expect(test_config.index.thumbnail_method).to eq(:create_thumb_img_element)
      end
    end

    describe 'commonwealth config fields' do
      it 'sets the fields for pseudo classes' do
        expect(test_config.collection_field).to eq('collection_name_ssim')
        expect(test_config.institution_field).to eq('institution_name_ssi')
        expect(test_config.series_field).to eq('related_item_series_ssi')
      end

      it 'sets the fields for full-text conifgs' do
        expect(test_config.ocr_search_field).to eq('ocr_tsiv')
        expect(test_config.page_num_field).to eq('page_num_label_ssi')
        expect(test_config.full_text_index).to eq('all_fields_ft')
      end

      it 'sets the fields for sorting' do
        expect(test_config.date_asc_sort).to be_truthy
        expect(test_config.title_sort).to be_truthy
      end
    end

    describe 'show document actions' do
      subject { test_config.show.document_actions }

      it 'adds the desired actions' do
        expect(subject[:sharing]).not_to be_empty
      end
    end
  end

  describe '#render_sharing?' do
    it 'returns the correct boolean value' do
      expect(mock_controller.send(:render_sharing?)).to be_truthy
    end
  end

  describe '#render_manifest_link?' do
    before(:each) do
      mock_controller.instance_variable_set(:@document, SolrDocument.find('bpl-dev:h702q6403'))
    end

    # remove the instance variables so they don't mess up other specs
    after(:each) do
      mock_controller.remove_instance_variable(:@document)
    end

    it 'returns the correct boolean value' do
      expect(mock_controller.send(:render_manifest_link?)).to be_truthy
    end
  end

  describe 'render_sms_action?' do
    it 'returns the correct boolean value' do
      expect(mock_controller.send(:render_sms_action?)).to be_falsey
    end
  end

  describe 'has_search_parameters?' do
    before(:each) { mock_controller.params = { mlt_id: 'bpl-dev:h702q6403' } }

    it 'returns true if mlt params are present' do
      expect(mock_controller.has_search_parameters?).to be_truthy
    end
  end
end
