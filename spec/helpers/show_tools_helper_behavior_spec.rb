# frozen_string_literal: true

require 'rails_helper'

describe CommonwealthVlrEngine::ShowToolsHelperBehavior do
  let(:document) { SolrDocument.find('bpl-dev:h702q6403') }

  describe '#social_sharing_links' do
    it 'returns an array of hashes with the correct structure' do
      helper.social_sharing_links(document).each do |link|
        expect(link.keys).to contain_exactly(:name, :icon, :color, :url)
        expect(link[:url]).to include(document['identifier_uri_ss'])
      end
    end
  end
end