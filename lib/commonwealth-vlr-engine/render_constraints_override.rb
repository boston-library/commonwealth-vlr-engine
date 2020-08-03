# override methods from Blacklight::RenderConstraintsHelperBehavior
module CommonwealthVlrEngine
  module RenderConstraintsOverride
    # override so we can inspect for other params, like :mlt_id
    def query_has_constraints?(params_or_search_state = search_state)
      search_state = convert_to_search_state(params_or_search_state)
      has_mlt_parameters?(search_state) || super
    end

    # return true if :mlt_id is present
    # @param search_state [Blacklight::SearchState]
    # @return [Boolean]
    def has_mlt_parameters?(search_state)
      search_state.params[:mlt_id].present?
    end

    # override to deal with A-Z link result display
    def render_constraint_element(label, value, options = {})
      if value.match(/ssort:[A-Z]+\*/)
        label = t('blacklight.search.constraints.az_search')
        value = value.match(/[A-Z]+/)[0]
      end
      options[:classes] ||= []
      options[:classes] << 'btn-group-sm'
      super
    end

    # override to add methods to show constraints for 'more like this' and advanced search date range
    def render_constraints(localized_params = params, local_search_state = search_state)
      params_or_search_state = if localized_params != params
                                 localized_params
                               else
                                 local_search_state
                               end
      render_mlt_query(params_or_search_state) + render_advanced_date_query(params_or_search_state) + super
    end

    # Render the advanced search date query constraints
    # @param params_or_search_state [Blacklight::SearchState || ActionController::Parameters]
    # @return [String]
    def render_advanced_date_query(params_or_search_state = search_state)
      search_state = convert_to_search_state(params_or_search_state)
      # So simple don't need a view template, we can just do it here.
      return ''.html_safe if search_state.params[:date_start].blank? && search_state.params[:date_end].blank?

      render_constraint_element(t('blacklight.advanced_search.constraints.date'),
                                date_range_constraints_to_s(search_state.params),
                                classes: ['date_range'],
                                remove: search_action_path(search_state.params.dup.except!(:date_start, :date_end)))
    end

    # Render the 'more like this' query constraints
    # @param params_or_search_state [Blacklight::SearchState || ActionController::Parameters]
    # @return [String]
    def render_mlt_query(params_or_search_state = search_state)
      search_state = convert_to_search_state(params_or_search_state)
      # So simple don't need a view template, we can just do it here.
      return ''.html_safe if search_state.params[:mlt_id].blank?

      render_constraint_element(t('blacklight.more_like_this.constraint_label'),
                                search_state.params[:mlt_id],
                                classes: ['mlt'],
                                remove: search_action_path(search_state.params.dup.except!(:mlt_id, :qt)))
    end

  end
end