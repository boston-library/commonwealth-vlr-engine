# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CommonwealthVlrEngine::HiergeoSubjectComponent, type: :component do
  let(:doc_with_geojson) { SolrDocument.find('bpl-dev:h702q6403') }
  let(:geojson_feature) { doc_with_geojson['subject_hiergeo_geojson_ssm'].first }
  let(:geojson_properties) { JSON.parse(geojson_feature).dig('properties') }

  it 'renders the component' do
    render_inline(described_class.new(geojson_feature: geojson_feature))

    expect(page).to have_link geojson_properties['state']
    expect(page).to have_link "#{geojson_properties['county']} (county)"
    expect(page).to have_link geojson_properties['city']
  end
end
