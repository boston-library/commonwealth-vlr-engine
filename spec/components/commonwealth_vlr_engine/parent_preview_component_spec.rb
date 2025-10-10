# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CommonwealthVlrEngine::ParentPreviewComponent, :vcr, type: :component do
  let(:document) { SolrDocument.find('bpl-dev:h702q6403') }

  it "renders the component" do
    render_inline(described_class.new(document: document))

    expect(page).to have_selector('#parent_preview_component')
    expect(page).to have_selector('.parent-image')
    expect(page).to have_link document['admin_set_name_ssi'], href: "/collections/#{document['admin_set_ark_id_ssi']}"
  end
end
