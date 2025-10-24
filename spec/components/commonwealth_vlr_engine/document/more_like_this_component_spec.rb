# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CommonwealthVlrEngine::Document::MoreLikeThisComponent, type: :component do
  subject(:render) do
    component.render_in(view_context)
  end

  let(:item_pid) { 'bpl-dev:00000007x' }
  let(:mlt_response) do
    mlt_search_service = Blacklight::SearchService.new(config: blacklight_config,
                                                       user_params: { mlt_id: item_pid, rows: 4 },
                                                       search_builder_class: CommonwealthVlrEngine::MltSearchBuilder)
    mlt_search_service.search_results
  end
  let(:component) { described_class.new(document: SolrDocument.find(item_pid), mlt_response: mlt_response) }
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
