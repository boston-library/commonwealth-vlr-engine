# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CommonwealthVlrEngine::Document::FlaggedWarningComponent, type: :component do
  let(:item_pid) { 'bpl-dev:00000007x' }
  let(:document) { SolrDocument.find(item_pid) }
  let(:component) { described_class.new(document: document) }
  subject(:render) do
    component.render_in(view_context)
  end
  let(:rendered) { Capybara::Node::Simple.new(render) }
  let(:view_context) { controller.view_context }

  before do
    without_partial_double_verification do
      allow(view_context).to receive_messages(current_search_session: nil)
    end
  end

  it 'renders the component' do
    expect(rendered).to have_selector('#flagged_warning_modal')
    expect(rendered).to have_content(I18n.t('blacklight.flagged.explicit.title'))
  end
end
