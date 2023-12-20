# frozen_string_literal: true

module CommonwealthVlrEngine
	module ShowToolsHelperBehavior
		def social_sharing_links
			url = @document['identifier_uri_ss']
			[
				{
					name: 'Facebook',
					icon: 'facebook-square',
					url: "https://www.facebook.com/sharer/sharer.php?u=#{url}"
        },
        {
					name: 'Pinterest',
					icon: 'pinterest-square',
					url: "https://pinterest.com/pin/create/link/?url=#{url}"
        },
        {
					name: 'X',
					icon: 'square-x-twitter',
					url: "https://twitter.com/intent/tweet?text=#{url}"
        },
        {
					name: 'Reddit',
					icon: 'reddit-square',
					url: "https://www.reddit.com/submit?url=#{url}"
        },
        {
					name: 'Tumblr',
					icon: 'tumblr-square',
					url: "https://www.tumblr.com/share/link?url=#{url}"
        }
			]
		end
	end
end