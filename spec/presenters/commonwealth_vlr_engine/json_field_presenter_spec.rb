# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CommonwealthVlrEngine::JsonFieldPresenter, api: true do
  subject(:presenter) { described_class.new({}, document, field_config) }

  let(:field_name) { 'genre_basic_ssim' }
  let(:blacklight_config) do
    Blacklight::Configuration.new.configure do |config|
      config.add_index_field field_name
    end
  end
  let(:field_config) { blacklight_config.index_fields[field_name] }
  let(:document) { SolrDocument.find('bpl-dev:h702q6403') }

  describe '#retrieve_values' do
    it 'returns the raw field value' do
      expect(subject.send(:retrieve_values)).to eq ['Photographs']
    end
  end
end
