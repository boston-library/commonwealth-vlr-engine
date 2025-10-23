# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CommonwealthVlrEngine::Document::HarvestedItemComponent, type: :component do
  let(:item_pid) { 'oai-dev:qv33s812k' }
  let(:document) { SolrDocument.find(item_pid) }

  it 'renders the component' do
    render_inline(described_class.new(document: document))
    puts "RENDERE: #{rendered_content}"

    expect(page).to have_css('#harvested_item_show_container')
    expect(page).to have_link(class: 'view_oai_item', href: 'https://hdl.handle.net/1912/66764')
  end
end
