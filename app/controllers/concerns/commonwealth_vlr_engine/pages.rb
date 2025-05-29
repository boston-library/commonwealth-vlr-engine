# frozen_string_literal: true

module CommonwealthVlrEngine
  module Pages
    extend ActiveSupport::Concern

    def home
      @banner_image = CarouselSlide.where(context: 'root').sample
    end
  end
end
