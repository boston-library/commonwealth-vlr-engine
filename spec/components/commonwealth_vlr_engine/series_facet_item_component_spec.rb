# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CommonwealthVlrEngine::SeriesFacetItemComponent, type: :component do
  let(:test_series) { 'Test Series' }
  let(:facet_item) do
    instance_double(
      Blacklight::FacetItemPresenter,
      facet_config: Blacklight::Configuration::FacetField.new,
      label: test_series,
      hits: 10,
      href: "/search?f%5Bcollection_name_ssim%5D%5B%5D=Carte+de+Visite+Collection&f%5Brelated_item_series_ssi%5D%5B%5D=#{test_series.split.join('+')}",
      selected?: false
    )
  end

  it 'renders the component' do
    render_inline(described_class.new(facet_item: facet_item))

    expect(page).to have_selector('.series_facet')
    expect(page).to have_selector('img.series_thumbnail', count: 1)
    expect(page).to have_link(test_series, href: facet_item.href)
  end
end
