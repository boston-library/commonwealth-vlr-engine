# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CommonwealthVlrEngine::DocumentTitleComponent, type: :component do
  subject(:render) do
    component.render_in(view_context)
  end

  let(:item_pid) { 'bpl-dev:qf85nb285' }
  let(:document) { SolrDocument.find(item_pid) }
  let(:request_context) { double(document_index_view_type: 'list') }
  let(:presenter) { CommonwealthVlrEngine::IndexPresenter.new(document, request_context, blacklight_config) }
  let(:component) { described_class.new(document: document, presenter: presenter) }
  let(:rendered) { Capybara::Node::Simple.new(render) }
  let(:view_context) { controller.view_context }
  let(:blacklight_config) do
    CatalogController.blacklight_config.deep_copy.tap do |config|
      config.track_search_session.storage = false
    end
  end

  before(:each) do
    without_partial_double_verification do
      allow(controller).to receive_messages(view_context: view_context, blacklight_config: blacklight_config)
      allow(view_context).to receive_messages(search_session: {}, current_search_session: nil)
    end
  end

  it 'renders the component with the correct title' do
    expect(rendered).to have_selector('h3.document-title-heading', count: 1)
    expect(rendered).to have_content('...')
  end
end
