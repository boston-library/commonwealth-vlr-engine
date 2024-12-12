# frozen_string_literal: true

module CommonwealthVlrEngine
  class BlogFeedComponent < ViewComponent::Base
    attr_reader :source, :posts

    def initialize(source: I18n.t('blacklight.home.news.rss_link'))
      @source = source
      @posts = fetch_blog_posts
    end

    def fetch_blog_posts
      Rails.cache.fetch('dc_rss_feed', expires_in: 60.minutes) do
        uri = URI.parse(source)
        RSS::Parser.parse(uri.open.read, false).items[0..3]
      end
    rescue
      []
    end
  end
end
