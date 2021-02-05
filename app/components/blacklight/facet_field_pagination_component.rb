# frozen_string_literal: true

# override to fix bug with upstream Blacklight in #sort_facet_url
# remove this file once https://github.com/projectblacklight/blacklight/pull/2425 is merged
# and this project is updated to use Blacklight version that includes that PR
module Blacklight
  class FacetFieldPaginationComponent < ::ViewComponent::Base
    def initialize(facet_field:)
      @facet_field = facet_field
    end

    def sort_facet_url(sort)
      @facet_field.paginator.params_for_resort_url(sort, @facet_field.search_state.to_h)
    end

    def param_name
      @facet_field.paginator.class.request_keys[:page]
    end
  end
end
