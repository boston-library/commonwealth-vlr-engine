# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'catalog/show.json' do
  let(:item_pid) { 'bpl-dev:h702q6403' }
  let(:document) { SolrDocument.find(item_pid) }
  let(:blacklight_config) { Blacklight::Configuration.new }
  let(:hash) do
    render template: 'catalog/show.json', format: :json
    JSON.parse(rendered).with_indifferent_access
  end
  let(:rendered_doc) { hash['data'] }

  before :each do
    allow(view).to receive(:blacklight_config).and_return(blacklight_config)
    allow(view).to receive_messages(blacklight_configuration_context: Blacklight::Configuration::Context.new(CatalogController.new))
    allow(view).to receive(:action_name).and_return('show')
    assign :document, document
  end

  it 'renders all document attributes' do
    expect(rendered_doc['id']).to eq item_pid
    expect(rendered_doc['attributes']['title_info_primary_tsi']).to eq 'Beauregard'
    expect(rendered_doc['attributes']['genre_basic_ssim']).to be_a_kind_of(Array)
    expect(rendered_doc['attributes']['subject_point_geospatial']).not_to be_blank
  end
end
