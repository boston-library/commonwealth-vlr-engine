# frozen_string_literal: true

module CommonwealthVlrEngine
  class SeriesComponent < ViewComponent::Base
    def initialize(response:, series_field_name:)
      @facet_item = response.aggregations.dig(series_field_name.to_sym)
    end

    def render?
      @facet_item&.items.present?
    end
  end
end
