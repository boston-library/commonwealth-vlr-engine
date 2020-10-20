# frozen_string_literal: true

module CommonwealthVlrEngine
  module Pages
    extend ActiveSupport::Concern

    def home
      @carousel_slides = CarouselSlide.where(context: 'root').order(:sequence)
      render 'pages/home'
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
