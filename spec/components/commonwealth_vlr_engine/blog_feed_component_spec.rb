# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CommonwealthVlrEngine::BlogFeedComponent, :vcr, type: :component do
  it 'renders the component' do
    render_inline(described_class.new(source: 'https://blog.digitalcommonwealth.org/?feed=rss2'))

    expect(page).to have_selector('#blog_feed_items')
    expect(page).to have_selector('.blog_feed_item_link', count: 3)
  end
end
