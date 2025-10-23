# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CommonwealthVlrEngine::Document::MetadataComponent, type: :component do
  let(:item_pid) { 'bpl-dev:00000007x' }
  let(:document) { SolrDocument.find(item_pid) }

  it 'renders the component' do
    render_inline(described_class.new(document: document))

    expect(page).to have_selector('#item_metadata')
    expect(page).to have_content(document[:title_info_alternative_tsim].first)
    expect(page).to have_link(document[:name_facet_ssim].first, href: "/search?f%5Bname_facet_ssim%5D%5B%5D=C.S.+Hammond+%26+Company")
    expect(page).to have_link(document[:identifier_uri_ss], href: document[:identifier_uri_ss])
  end
end
