# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'catalog/index.json', api: true do
  let(:response) { instance_double(Blacklight::Solr::Response, documents: docs, prev_page: nil, next_page: 2, total_pages: 3) }
  let(:docs) { [SolrDocument.find('bpl-dev:h702q6403')] }
  let(:field_name) { 'genre_basic_ssim' }
  let(:config) do
    Blacklight::Configuration.new.configure do |config|
      config.add_index_field field_name
    end
  end
  let(:presenter) { Blacklight::JsonPresenter.new(response, config) }
  let(:mock_controller) { CatalogController.new }
  let(:search_state) { Blacklight::SearchState.new({}, config, mock_controller) }

  let(:hash) do
    render template: 'catalog/index', formats: [:json]
    JSON.parse(rendered).with_indifferent_access
  end

  before(:each) do
    without_partial_double_verification do
      allow(view).to receive_messages(blacklight_config: config,
                                      search_action_path: 'http://test.host/some/search/url',
                                      search_facet_path: 'http://test.host/some/facet/url')
      allow(view).to receive(:search_state).and_return(search_state)
      allow(view).to receive_messages(blacklight_configuration_context: Blacklight::Configuration::Context.new(mock_controller))
    end
    allow(presenter).to receive_messages(pagination_info: { current_page: 1, next_page: 2, prev_page: nil })
    assign :presenter, presenter
    assign :response, response
  end

  it 'returns the documents with correctly formatted values' do
    expect(hash[:data].first[:attributes][field_name]).to eq ['Photographs']
  end
end
