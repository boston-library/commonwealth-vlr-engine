# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CommonwealthVlrEngine::AzLinksComponent, type: :component do
  let(:context_arg) { 'collections' }

  it 'renders the component' do
    render_inline(described_class.new(context: context_arg))

    expect(page).to have_selector('.az_link', count: 27)
    expect(page).to have_link 'A', href: "/#{context_arg}?starts_with=A"
  end
end
