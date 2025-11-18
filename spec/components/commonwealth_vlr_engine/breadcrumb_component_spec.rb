# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CommonwealthVlrEngine::BreadcrumbComponent, type: :component do
  let(:document) { SolrDocument.find('bpl-dev:h702q6403') }

  it 'renders the component' do
    render_inline(described_class.new(document: document))

    expect(page).to have_selector('#item_breadcrumb')
    expect(page).to have_selector('#institution_breadcrumb')
    expect(page).to have_link document['admin_set_name_ssi'], href: "/collections/#{document['admin_set_ark_id_ssi']}"
  end
end
