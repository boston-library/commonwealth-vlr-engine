# frozen_string_literal: true

require 'rails_helper'

RSpec.describe BlacklightIiifSearch::SearchBehavior do
  let(:parent_id) { 'abc123' }
  let(:search_params) do
    { q: 'whatever', solr_document_id: parent_id }
  end
  let(:controller) { CatalogController.new }
  let(:blacklight_config) { controller.blacklight_config }
  let(:parent_document) do
    SolrDocument.new('id' => parent_id)
  end
  let(:iiif_search) do
    BlacklightIiifSearch::IiifSearch.new(search_params,
                                         blacklight_config.iiif_search,
                                         parent_document)
  end

  describe '#object_relation_solr_params' do
    subject { iiif_search.object_relation_solr_params }

    it 'returns a hash with the correct content' do
      expect(subject.keys).to include('is_file_set_of_ssim')
      expect(subject.values).to include("info:fedora/#{parent_id}")
    end
  end
end
