# frozen_string_literal: true

module CommonwealthVlrEngine
  module Pages
    extend ActiveSupport::Concern

    def home
      @banner_image = CarouselSlide.where(context: 'root').sample
    end

    def about_site
      @nav_li_active = 'about'
    end
  end
end
