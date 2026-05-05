# frozen_string_literal: true

module CommonwealthVlrEngine
  module Pages
    extend ActiveSupport::Concern

    # allows access to CatalogController configuration, so we can display SolrDocument objects
    included do
      include Blacklight::Catalog
      copy_blacklight_config_from(CatalogController)

      # set this here, or in downstream PagesController
      # ensures the header search form has the correct action
      def search_action_url(_options = {})
        search_catalog_url(controller: 'catalog')
      end

      before_action :set_featured_objects, only: :home
      helper_method :search_action_url
    end

    def home
      @banner_image = CarouselSlide.where(context: 'root').sample
    end

    def about_site
      @nav_li_active = 'about'
    end

    private

    def set_featured_objects
      featured_search_service = Blacklight::SearchService.new(config: blacklight_config, search_builder_class: SearchBuilder)
      @featured_items = featured_search_service.fetch(helpers.featured_objects_from_config(context: 'root'))
      @featured_collections = featured_search_service.fetch(helpers.featured_objects_from_config(context: 'root',
                                                                                                 type: 'collections'))
    end
  end
end
