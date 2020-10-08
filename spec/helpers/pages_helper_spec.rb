require 'rails_helper'

describe PagesHelper do
  describe '#render_blog_feed' do
    let(:rendered_feed) { helper.render_blog_feed(File.open(File.expand_path(File.join('..', '..', 'fixtures', 'sample_rss_feed.xml'), __FILE__))) }

    it 'creates the correct HTML content' do
      expect(rendered_feed).to include('<ul class="feed_items">')
      expect(rendered_feed).to include('<li class="feed_item">')
      expect(rendered_feed).to include('href="http://blog.somelibrary.org/?p=942">Event 1')
    end

    it 'has 4 items' do
      expect(rendered_feed.scan(/<li class="feed_item">/).count).to eq(4)
    end
  end
end
