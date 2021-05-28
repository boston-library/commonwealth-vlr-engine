# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CommonwealthVlrEngine::JsonIndexPresenter, api: true do
  subject { presenter }

  let(:request_context) { double(document_index_view_type: 'list') }
  let(:blacklight_config) { Blacklight::Configuration.new }
  let(:document) { SolrDocument.find('bpl-dev:h702q6403') }
  let(:presenter) { described_class.new(document, request_context, blacklight_config) }

  describe '#display_type' do
    before :each do
      blacklight_config.index.display_type_field = :curator_model_suffix_ssi
    end

    it 'returns the value as an array' do
      expect(presenter.display_type).to eq ['PhotographicPrint']
    end
  end

  describe '#fields' do
    let(:all_fields) { subject.send(:fields) }

    it 'returns all document fields' do
      expect(all_fields.length).to be > 50
      expect(all_fields['date_start_dtsi']).not_to be_falsey
      expect(all_fields['genre_basic_ssim']).not_to be_falsey
    end
  end

  describe '#field_presenter' do
    let(:field_config) { Blacklight::Configuration::Field.new }

    it 'returns JsonFieldPresenter' do
      expect(subject.send(:field_presenter, field_config)).to be_a_kind_of CommonwealthVlrEngine::JsonFieldPresenter
    end
  end
end
