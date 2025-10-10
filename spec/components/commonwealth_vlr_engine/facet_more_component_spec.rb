# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CommonwealthVlrEngine::FacetMoreComponent, type: :component do
  subject(:render) do
    component.render_in(view_context)
  end
  let(:rendered) { Capybara::Node::Simple.new(render) }
  let(:view_context) { controller.view_context }
  let(:blacklight_config) do
    CatalogController.blacklight_config.deep_copy.tap do |config|
      config.track_search_session.storage = false
    end
  end

  before do
    without_partial_double_verification do
      allow(controller).to receive_messages(view_context: view_context, blacklight_config: blacklight_config)
      allow(view_context).to receive_messages(search_session: {}, current_search_session: nil)
    end
  end

  describe 'when a SolrDocument arg is passed' do
    let(:document) { SolrDocument.find('bpl-dev:h702q6403') }
    let(:component) { described_class.new(document: document) }

    it "renders the component and 'more' items" do
      expect(rendered).to have_selector('#documents_facet_more .document')
    end
  end

  describe 'when a subject_term arg is passed' do
    let(:component) { described_class.new(subject_term: 'Boston (Mass.)--Maps') }

    it "renders the component and 'more' items" do
      expect(rendered).to have_selector('#documents_facet_more .document')
    end
  end

  describe 'when a Blacklight::Solr::Response is passed' do
    # mock response so we can pick facet field/value where #facet_more_documents returns an Array of SolrDocuments
    let(:response) do
      Blacklight::Solr::Response.new({ facet_counts: { facet_fields: { subject_facet_ssim: { 'Boston (Mass.)--Maps' => 2, 'Arctic regions--Maps' => 1 } } } }.with_indifferent_access,
                                     { fq: ["{!term f=subject_facet_ssim}Boston (Mass.)--Maps"] }.with_indifferent_access)
    end
    let(:component) { described_class.new(response: response) }

    it "renders the component and 'more' items" do
      expect(rendered).to have_selector('#documents_facet_more .document')
    end
  end
end
