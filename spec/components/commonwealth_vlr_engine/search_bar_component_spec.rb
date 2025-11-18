# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CommonwealthVlrEngine::SearchBarComponent, type: :component do
  it 'renders the component, simplifying search field names' do
    render_inline(described_class.new(url: '/search', params: {}))

    expect(page).to have_selector('#search_field option', count: 5)
    expect(page).to have_css('#search_field option', text: 'All Fields')
  end
end
