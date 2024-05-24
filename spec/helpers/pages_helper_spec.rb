# frozen_string_literal: true

require 'rails_helper'

describe PagesHelper, :vcr do
  describe '#render_blog_feed' do
    let(:rendered_feed) { helper.render_blog_feed('https://blog.digitalcommonwealth.org/?feed=rss2') }

    it 'creates the correct HTML content' do
      expect(rendered_feed).to include('<ul class="feed_items">')
      expect(rendered_feed).to include('<li class="feed_item">')
      expect(rendered_feed).to include('href="https://blog.digitalcommonwealth.org/?p=2949">DC3 Repository System: An Overview')
    end

    it 'has 4 items' do
      expect(rendered_feed.scan(/<li class="feed_item">/).count).to eq(4)
    end
  end

  describe '#middle_feature_columns' do
    it 'returns the CSS class' do
      expect(helper.middle_feature_columns).to eq('col-sm-6 col-md-6 col-lg-3')
    end
  end

  describe '#render_about_site_path' do
    it 'returns the about path' do
      expect(helper.render_about_site_path).to eq('/about_this_site')
    end
  end
end
