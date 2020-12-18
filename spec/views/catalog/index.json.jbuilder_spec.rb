# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'catalog/index.json', api: true do
  let(:item_pid) { 'bpl-dev:h702q6403' }
  let(:docs) { [SolrDocument.find(item_pid)] }
  let(:response) { instance_double(Blacklight::Solr::Response, documents: docs, prev_page: nil, next_page: 2, total_pages: 3) }
  let(:blacklight_config) { Blacklight::Configuration.new }
  let(:presenter) { Blacklight::JsonPresenter.new(response, blacklight_config) }
  let(:search_state) { Blacklight::SearchState.new({}, blacklight_config, controller) }
  let(:hash) do
    render template: 'catalog/index.json', format: :json
    JSON.parse(rendered).with_indifferent_access
  end
  let(:rendered_doc) { hash['data'].first }

  before :each do
    allow(view).to receive(:blacklight_config).and_return(blacklight_config)
    allow(view).to receive(:search_state).and_return(search_state)
    allow(view).to receive_messages(blacklight_configuration_context: Blacklight::Configuration::Context.new(CatalogController.new))
    allow(presenter).to receive(:pagination_info).and_return(current_page: 1,
                                                             next_page: 2,
                                                             prev_page: nil)
    assign :presenter, presenter
    assign :response, response
  end

  it 'renders all document attributes' do
    expect(rendered_doc['id']).to eq item_pid
    expect(rendered_doc['attributes']['active_fedora_model_ssi']).to eq 'Bplmodels::PhotographicPrint'
    expect(rendered_doc['attributes']['has_model_ssim']).to be_a_kind_of(Array)
    expect(rendered_doc['attributes']['harvesting_status_bsi']).to be_truthy
  end
end
