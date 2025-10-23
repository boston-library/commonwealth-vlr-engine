# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CommonwealthVlrEngine::Document::MoreLikeThisComponent, type: :component do
  subject(:render) do
    component.render_in(view_context)
  end

  let(:mlt_documents) { [SolrDocument.find('bpl-dev:00000003t'), SolrDocument.find('bpl-dev:00000007x')] }
  # TODO: figure out how to mock response with documents
  let(:mlt_response) do
    Blacklight::Solr::Response.new({ response: { documents: mlt_documents } }.with_indifferent_access, {})
  end
  let(:component) { described_class.new(document: SolrDocument.find('bpl-dev:h702q6403'), mlt_response: mlt_response) }
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

  it "renders the component" do
    expect(rendered).to have_selector('#more_like_this')
    expect(rendered).to have_selector('#more_like_this_docs .document', count: 4)
  end
end
