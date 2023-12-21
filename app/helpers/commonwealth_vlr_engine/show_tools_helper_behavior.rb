# frozen_string_literal: true

module CommonwealthVlrEngine
  module ShowToolsHelperBehavior
    def social_sharing_links(document)
      url = document['identifier_uri_ss']
      [
        {
          name: 'Facebook',
          icon: 'facebook-square',
          color: '#1877f2',
          url: "https://www.facebook.com/sharer/sharer.php?u=#{url}"
        },
        {
          name: 'Pinterest',
          icon: 'pinterest-square',
          color: '#e60023',
          url: "https://pinterest.com/pin/create/link/?url=#{url}"
        },
        {
          name: 'X',
          icon: 'square-x-twitter',
          color: '#000000',
          url: "https://twitter.com/intent/tweet?text=#{url}"
        },
        {
          name: 'Reddit',
          icon: 'reddit-square',
          color: '#ff4500',
          url: "https://www.reddit.com/submit?url=#{url}"
        },
        {
          name: 'Tumblr',
          icon: 'tumblr-square',
          color: '#35465c',
          url: "https://www.tumblr.com/share/link?url=#{url}"
        }
      ]
    end
  end
end