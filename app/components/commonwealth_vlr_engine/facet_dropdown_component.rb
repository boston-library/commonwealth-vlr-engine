# frozen_string_literal: true

# used to render facet values as a dropdown
module CommonwealthVlrEngine
  class FacetDropdownComponent < ViewComponent::Base
    attr_reader :facet_field_name

    # @param [Blacklight::Response] response
    # @param [Symbol] facet_field_name
    def initialize(response:, facet_field_name: nil, search_state:)
      @response = response
      @facet_field_name = facet_field_name
      @facet_item = @response.aggregations.dig(facet_field_name)
      @search_state = search_state
    end

    def render?
      @facet_item.present?
    end

    # return 2d array like:
    # [["relevance", "score desc, title_info_primary_ssort asc"],
    #  ["title", "title_info_primary_ssort asc, date_start_dtsi asc"]]
    def dropdown_choices
      facet_field_config = helpers.facet_configuration_for_field(facet_field_name)
      facet_field_presenter = facet_field_config.presenter.new(facet_field_config, @facet_item, controller.view_context)
      @facet_item.items.filter_map do |fi|
        next if fi.value == 'Collections'

        fi_presenter = facet_field_config.item_presenter.new(fi, facet_field_config, controller.view_context, facet_field_presenter, @search_state)
        ["#{fi_presenter.label} (#{fi.hits})", fi.value]
      end
    end

    def dropdown
      render(CommonwealthVlrEngine::System::DropdownComponent.new(
        param: "f[#{facet_field_name}][]",
        choices: dropdown_choices,
        id: "#{facet_field_name}-dropdown",
        search_state: @search_state #,
        # selected:
      ))
    end
  end
end
