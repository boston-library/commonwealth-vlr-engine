# frozen_string_literal: true

module CommonwealthVlrEngine
  module FacetsHelper
    include Blacklight::FacetsHelperBehavior

    # LOCAL OVERRIDE
    # don't display 'Collections' genre_basic_ssim facet value
    # on collections#index or collections#facet views
    # def render_facet_item(facet_field, item)
    #   return if controller.controller_name == 'collections' &&
    #       (controller.action_name == 'index' || controller.action_name == 'facet') &&
    #       item.value == 'Collections'
    #
    #   if facet_in_params?(facet_field, facet_value_for_facet_item(item))
    #     render_selected_facet_value(facet_field, item)
    #   else
    #     render_facet_value(facet_field, item)
    #   end
    # end
  end
end
