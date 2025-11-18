# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CommonwealthVlrEngine::SeriesComponent, type: :component do
  let(:mock_controler) { CollectionsController.new }
  let(:blacklight_config) do
    CollectionsController.blacklight_config.deep_copy.tap do |config|
      config.track_search_session.storage = false
      config.facet_fields[mock_controler.blacklight_config.series_field].include_in_request = true
    end
  end
  let(:search_service) do
    mock_controler.search_service_class.new(config: blacklight_config, user_params: {})
  end
  let(:response) { search_service.search_results }
  let(:view_context) { controller.view_context }
  let(:test_series) { 'Test Series' }

  before(:each) do
    allow(controller).to receive_messages(view_context: view_context)
    allow(view_context).to receive(:search_action_path).with({ 'f' => { blacklight_config.series_field => [test_series] } }).and_return("/search?f%5Bcollection_name_ssim%5D%5B%5D=Carte+de+Visite+Collection&f%5Brelated_item_series_ssi%5D%5B%5D=#{test_series.split.join('+')}")
  end

  it 'renders the component, and a collection of SeriesFacetItemComponent objects' do
    render_inline(described_class.new(response: response, series_field_name: blacklight_config.series_field))

    expect(page).to have_selector('#series')
    expect(page).to have_link(test_series)
  end
end
