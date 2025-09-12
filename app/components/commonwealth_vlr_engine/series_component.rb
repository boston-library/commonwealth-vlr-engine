# frozen_string_literal: true

module CommonwealthVlrEngine
  class SeriesComponent < ViewComponent::Base
    def initialize(response:, series_field_name:)
      @response = response
      @series_field_name = series_field_name.to_sym
      @facet_item = @response.aggregations.dig(@series_field_name)
      # @search_state = search_state
    end

    def render?
      @facet_item.present?
    end
  end
end
