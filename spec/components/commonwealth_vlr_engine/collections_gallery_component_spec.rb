# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CommonwealthVlrEngine::CollectionsGalleryComponent, type: :component do
  subject(:render) do
    component.render_in(view_context)
  end

  let(:collection_documents) { [SolrDocument.find('bpl-dev:000000000'), SolrDocument.find('bpl-dev:h702q636h')] }
  let(:component) { described_class.new(collection_documents: collection_documents) }
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

  it 'renders the component' do
    expect(rendered).to have_selector('#documents_collections')
    expect(rendered).to have_selector('.blacklight-collection.document', count: collection_documents.size)
  end
end
