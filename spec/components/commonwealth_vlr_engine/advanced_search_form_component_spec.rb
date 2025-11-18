# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CommonwealthVlrEngine::AdvancedSearchFormComponent, type: :component do
  subject(:render) do
    component.render_in(view_context)
  end

  let(:component) { described_class.new(url: '/foo', response: response, params: params) }
  let(:response) { Blacklight::Solr::Response.new({ facet_counts: { facet_fields: { format: { 'Book' => 10, 'CD' => 5 } } } }.with_indifferent_access, {}) }
  let(:params) { {} }

  let(:rendered) do
    Capybara::Node::Simple.new(render)
  end

  let(:view_context) { controller.view_context }

  before(:each) do
    without_partial_double_verification do
      allow(view_context).to receive(:facet_limit_for).and_return(nil)
    end
  end

  it 'does not include a sort field' do
    expect(component.sort_fields_select).to be_falsey
    expect(rendered).to_not have_css '.sort-select'
  end

  it 'has search_index_select fields with the correct options' do
    expect(rendered).to have_selector('.search_index_select', count: 3)
    expect(rendered).to have_select 'clause_0_field', options: controller.blacklight_config.search_fields.values.map(&:label)
  end
end
