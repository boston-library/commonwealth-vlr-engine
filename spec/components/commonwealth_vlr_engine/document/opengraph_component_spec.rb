# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CommonwealthVlrEngine::Document::OpengraphComponent, :vcr, type: :component do
  subject(:render) do
    component.render_in(view_context)
  end

  let(:rendered) { Capybara::Node::Simple.new(render) }
  let(:view_context) { controller.view_context }
  let(:component) { described_class.new(document: document, exemplary_document: exemplary_document, object_files: object_files) }
  let(:mock_controller) { CatalogController.new }
  let(:document) { SolrDocument.find(item_pid) }
  let(:object_files) { mock_controller.get_files(item_pid) }

  before(:each) do
    allow(controller).to receive_messages(controller_name: controller_name, action_name: 'show')
  end

  describe 'for DigitalObject' do
    let(:controller_name) { 'catalog' }

    describe 'hosted item' do
      let(:item_pid) { 'bpl-dev:h702q6403' }
      let(:exemplary_document) { nil }

      it 'renders the component with the correct values' do
        expect(rendered).to have_selector("meta[property=\"og:url\"][content=\"#{document[:identifier_uri_ss]}\"]", visible: :hidden)
        expect(rendered).to have_selector("meta[property=\"og:image\"][content=\"#{document[:identifier_uri_ss]}/large_image\"]", visible: :hidden)
      end
    end

    describe 'harvested item' do
      let(:item_pid) { 'oai-dev:qv33s812k' }
      let(:exemplary_document) { nil }

      it 'renders the component with the correct values' do
        expect(rendered).to have_selector("meta[property=\"og:url\"][content=\"http://test.host/search/#{item_pid}\"]", visible: :hidden)
        expect(rendered).to have_selector("meta[property=\"og:image\"][content=\"#{CommonwealthVlrEngine.config['asset_store_url']}/derivatives/#{document[:exemplary_image_key_base_ss]}/image_thumbnail_300.jpg\"]", visible: :hidden)
      end
    end
  end

  describe 'for Collection' do
    let(:controller_name) { 'collections' }
    let(:item_pid) { 'bpl-dev:h702q636h' }
    let(:exemplary_document) { SolrDocument.find(document[:exemplary_image_digobj_ss]) }

    it 'renders the component with the correct values' do
      expect(rendered).to have_selector("meta[property=\"og:url\"][content=\"http://test.host/#{controller_name}/#{item_pid}\"]", visible: :hidden)
      expect(rendered).to have_selector("meta[property=\"og:image\"][content=\"#{CommonwealthVlrEngine.config['iiif_server_url']}#{exemplary_document[:exemplary_image_ssi]}/0,0,0,0/0,/0/default.jpg\"]", visible: :hidden)
    end
  end
end
