# frozen_string_literal: true

module CommonwealthVlrEngine
  class MltFilterField < Blacklight::SearchState::FilterField
    def initialize(*args)
      super
      @filters_key = :mlt_id
    end

    # @param [String,#value] a filter item to add to the url
    # @return [Blacklight::SearchState] new state
    def add(item)
      new_state = search_state.reset_search
      params = new_state.params
      value = as_url_parameter(item)

      params[filters_key] = value.to_param

      new_state.reset(params)
    end

    # @param [String,#value] a filter to remove from the url
    # @return [Blacklight::SearchState] new state
    def remove(_item)
      new_state = search_state.reset_search
      params = new_state.params

      params.delete(filters_key)
      new_state.reset(params)
    end

    # @return [Array] an array of applied filters
    def values(except: [])
      params = search_state.params
      return [] if except.include?(:filters) || params[filters_key].blank?

      [params[filters_key]]
    end

    # @param [String,#value] a filter to remove from the url
    # @return [Boolean] whether the provided filter is currently applied/selected
    delegate :include?, to: :values
  end
end
