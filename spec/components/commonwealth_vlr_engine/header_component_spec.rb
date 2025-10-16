# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CommonwealthVlrEngine::HeaderComponent, type: :component do
  it 'renders the component' do
    render_inline(described_class.new(blacklight_config: CatalogController.blacklight_config))

    expect(page).to have_css 'nav.topbar'
    expect(page).to have_link I18n.t('blacklight.application_name'), href: '/'
    expect(page).to have_link I18n.t('blacklight.header_links.collections'), href: '/collections'
  end
end
