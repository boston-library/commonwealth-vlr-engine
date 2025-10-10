# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CommonwealthVlrEngine::FacetDropdownComponent, type: :component do
  let(:controller) { CollectionsController.new }
  let(:blacklight_config) do
    CatalogController.blacklight_config.deep_copy.tap do |config|
      config.search_builder_class = CommonwealthVlrEngine::CollectionsSearchBuilder
    end
  end
  let(:search_service) do
    controller.search_service_class.new(config: blacklight_config, user_params: {})
  end
  let(:response) { search_service.search_results }
  let(:facet_field_name) { :genre_basic_ssim }
  let(:search_state) { Blacklight::SearchState.new(query_params.with_indifferent_access, blacklight_config, controller) }
  let(:query_params) { { controller: 'collections', action: 'index' } } # or else we get ActionController::UrlGenerationError

  before(:each) do
    allow(search_state).to receive(:params_for_search).and_return(query_params)
  end

  it 'renders a dropdown with a link for each facet value' do
    render_inline(described_class.new(response: response, facet_field_name: facet_field_name,
                                      search_state: search_state))

    expect(page).to have_selector("##{facet_field_name}-dropdown")
    expect(page).to have_selector('a.dropdown-item', count: 6)
  end

  describe 'with a selected facet value' do
    let(:query_params) { { controller: 'collections', action: 'index', f: { facet_field_name => %w(Photographs) } } }

    it 'adds the active class for selected facet values' do
      render_inline(described_class.new(response: response, facet_field_name: facet_field_name,
                                        search_state: search_state))

      expect(page).to have_selector("##{facet_field_name}-dropdown .dropdown-item.active")
    end

  end
end
