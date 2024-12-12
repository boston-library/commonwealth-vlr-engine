# frozen_string_literal: true

module CommonwealthVlrEngine
  module Pages
    extend ActiveSupport::Concern

    def home
      @banner_image = CarouselSlide.where(context: 'root').sample
      # render 'pages/home'
    end

    def about
      @nav_li_active = 'about'
    end

    def about_site
      @nav_li_active = 'about'
    end

    def explore
      @nav_li_active = 'explore'
    end
  end
end
