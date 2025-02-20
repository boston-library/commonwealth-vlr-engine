# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'catalog/_field.json.jbuilder', api: true do
  let(:field_name) { 'genre_basic_ssim' }
  let(:blacklight_config) do
    Blacklight::Configuration.new.configure do |config|
      config.add_index_field field_name
    end
  end
  let(:field_config) { blacklight_config.index_fields[field_name] }
  let(:document) { SolrDocument.find('bpl-dev:h702q6403') }

  let(:field_presenter) { CommonwealthVlrEngine::JsonFieldPresenter.new({}, document, field_config) }
  let(:hash) do
    render template: 'catalog/_field.json.jbuilder', format: :json
    JSON.parse(rendered).with_indifferent_access
  end

  before :each do
    allow(view).to receive(:field_name).and_return(field_name)
    allow(view).to receive(:field_presenter).and_return(field_presenter)
  end

  it 'returns the raw field value' do
    expect(hash[field_name]).to eq ['Photographs']
  end
end
