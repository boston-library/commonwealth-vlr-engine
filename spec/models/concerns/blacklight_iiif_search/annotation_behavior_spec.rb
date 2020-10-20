# frozen_string_literal: true

require 'rails_helper'

RSpec.describe BlacklightIiifSearch::AnnotationBehavior do
  let(:query_term) { 'software' }
  let(:page_doc_ark) { '3j334628j' }
  let(:page_doc) { SolrDocument.find("bpl-dev:#{page_doc_ark}") }
  let(:controller) { CatalogController.new }
  let(:parent_doc) { SolrDocument.find('bpl-dev:3j334603p') }
  let(:iiif_search_annotation) do
    BlacklightIiifSearch::IiifSearchAnnotation.new(page_doc, query_term,
                                                   0, nil, controller,
                                                   parent_doc)
  end
  let(:test_request) { ActionDispatch::TestRequest.new({}) }

  before(:each) { allow(controller).to receive(:request).and_return(test_request) }

  describe '#annotation_id' do
    it 'returns a properly formatted URL' do
      expect(iiif_search_annotation.annotation_id).to include(
        "#{parent_doc[:identifier_uri_ss]}/annotation/#{page_doc_ark}#0"
      )
    end
  end

  describe 'canvas_uri methods' do
    # stub #fetch_and_parse_coords, we don't have any djvuCoords datastreams in Fedora dev
    let(:coordinates) do
      JSON.parse("{\"width\":2421,\"height\":4080,\"words\":{\"#{query_term}\":[[1056,3500,1126,3452]]}}")
    end
    before(:each) { allow(iiif_search_annotation).to receive(:fetch_and_parse_coords).and_return(coordinates) }

    describe '#canvas_uri_for_annotation' do
      it 'returns a properly formatted URL' do
        expect(iiif_search_annotation.canvas_uri_for_annotation).to include(
          "#{parent_doc[:identifier_uri_ss]}/canvas/#{page_doc_ark}"
        )
      end
    end

    describe '#coordinates' do
      it 'gets the expected value from #coordinates' do
        expect(iiif_search_annotation.coordinates).to include('#xywh=1056,3452,70,48')
      end
    end
  end
end
