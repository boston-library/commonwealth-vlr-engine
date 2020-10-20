# frozen_string_literal: true

require 'rails_helper'

describe OaiItemHelper do
  let(:blacklight_config) { CatalogController.blacklight_config }
  let(:document) { SolrDocument.find('bpl-dev:h702q6403') }

  before(:each) do
    allow(helper).to receive_messages(blacklight_config: blacklight_config)
  end

  describe '#oai_inst_name' do
    it 'returns the institution name' do
      expect(helper.oai_inst_name(document)).to eq('Boston Public Library')
    end
  end

  describe '#oai_link_text' do
    it 'returns the correct link text' do
      expect(helper.oai_link_text(document)).to include('View the full image')
    end
  end
end
