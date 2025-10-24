# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CommonwealthVlrEngine::System::DropdownComponent, type: :component do
  it 'includes a link for each choice' do
    search_state = double(Blacklight::SearchState)
    allow(search_state).to receive(:params_for_search).and_return('http://example.com')
    render_inline(described_class.new(
      param: 'f[facet_field_name_ssim][]',
      choices: [
        %w[foo bar],
        %w[baz quux]
      ],
      search_state: search_state,
    ))

    expect(page).to have_css('.dropdown-item', count: 2)
  end
end
