class PagesController < ApplicationController

  def home
    #@carousel_slides = CarouselSlide.where(:context=>'root').order(:sequence)
  end

  def about
    @nav_li_active = 'about'
  end

  def explore
    @nav_li_active = 'explore'
  end

end


