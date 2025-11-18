# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CommonwealthVlrEngine::BannerImageComponent, :vcr, type: :component do
  let(:context_arg) { 'collection' }
  let(:exemplary_document) { SolrDocument.find('bpl-dev:h702q6403') }

  it 'renders the component' do
    render_inline(described_class.new(exemplary_document: exemplary_document, context: context_arg))

    expect(page).to have_selector('#banner_image_container')
    expect(page).to have_selector("img.banner-image-#{context_arg}")
    expect(page).to have_link 'Beauregard', href: "/search/#{exemplary_document['id']}"
  end
end
