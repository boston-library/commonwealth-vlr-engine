# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CommonwealthVlrEngine::Document::MetadataFieldComponent, type: :component do
  let(:item_pid) { 'bpl-dev:00000003t' }
  let(:document) { SolrDocument.find(item_pid) }
  let(:mock_controller) { CatalogController.new }
  let(:blacklight_config) { mock_controller.blacklight_config }
  let(:field_key) { 'title' }

  context 'with helper method argument' do
    it 'renders the component' do
      render_inline(described_class.new(document: document, field_name: blacklight_config.index.title_field.field,
                                        field_key: field_key, helper_method: :render_title))

      expect(page).to have_css('dt', text: I18n.t("blacklight.metadata_display.fields.#{field_key}"))
      expect(page).to have_css('dd', text: mock_controller.helpers.render_title(document))
    end
  end

  context 'with link: true argument' do
    let(:field_name) { :lang_term_ssim }

    it 'renders the component' do
      render_inline(described_class.new(document: document, field_name: field_name, field_key: 'language', link: true))

      # for some BIZARRE reason, can't use document[field_name] below
      expect(page).to have_link 'English', href: "/search?f%5B#{field_name}%5D%5B%5D=English"
    end
  end
end
