# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CommonwealthVlrEngine::FeaturedItemsComponent, type: :component do
  subject(:render) do
    component.render_in(view_context)
  end

  let(:featured_documents) { [SolrDocument.find('bpl-dev:g445cd14k'), SolrDocument.find('bpl-dev:h702q6403')] }
  let(:parent_document) { SolrDocument.find('bpl-dev:abcd12345') }
  let(:component) { described_class.new(featured_documents: featured_documents, parent_document: parent_document) }
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
    expect(rendered).to have_selector('#documents_featured')
    expect(rendered).to have_selector('.blacklight-digitalobject.document', count: featured_documents.size)
  end
end
