# frozen_string_literal: true

require 'rails_helper'

describe CommonwealthVlrEngine::FlaggedHelperBehavior do
  let(:blacklight_config) { CatalogController.blacklight_config }

  before(:each) do
    allow(helper).to receive_messages(blacklight_config: blacklight_config)
  end

  describe '#show_explicit_warning?' do
    let(:document) { SolrDocument.find('bpl-dev:00000007x') }

    it 'returns true if the item is explicit' do
      expect(helper.show_explicit_warning?(document)).to be_truthy
    end
  end

  describe '#show_content_warning?' do
    let(:document) { SolrDocument.find('bpl-dev:g445cd14k') }

    it 'returns true if the item is offensive' do
      expect(helper.show_content_warning?(document)).to be_truthy
    end
  end
end
