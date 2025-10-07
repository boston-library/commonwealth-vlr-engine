# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CommonwealthVlrEngine::IndexPresenter do
  subject { described_class.new(document, request_context, blacklight_config) }

  let(:request_context) { double(document_index_view_type: 'list') }
  let(:field_name) { 'foo_bar_ssim' }
  let(:blacklight_config) do
    Blacklight::Configuration.new.configure do |config|
      config.add_index_field field_name
    end
  end
  let(:document) { SolrDocument.find('bpl-dev:h702q6403') }

  describe '#display_fields' do
    let(:fields) { subject.send(:display_fields) }

    it 'returns the configured index fields' do
      expect(fields[field_name]).to be_a_kind_of Blacklight::Configuration::IndexField
    end
  end
end
