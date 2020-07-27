module CommonwealthVlrEngine
  module Pages
    extend ActiveSupport::Concern

    def home
      @carousel_slides = CarouselSlide.where(context: 'root').order(:sequence)
      section_active_count = 0
      sections = %w(maps collections institutions formats)
      sections.each do |section|
        if t("blacklight.home.browse.#{section}.enabled")
          section_active_count += 1
        end
      end

      @middle_feature_columns = 12 / section_active_count

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
