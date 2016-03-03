# Meant to be applied on top of Blacklight view helpers, to over-ride
# certain methods from RenderConstraintsHelper,
# to affect constraints rendering
module CommonwealthVlrEngine
  module RenderConstraintsOverride

    # override so we can inspect for other params, like :mlt_id
    def has_search_parameters?
      has_mlt_parameters? || super
      #!params[:q].blank? or !params[:f].blank? or !params[:search_field].blank? or params[:mlt_id] or !params[:coordinates].blank?
    end

    # return true if :mlt_id is present
    def has_mlt_parameters?
      !params[:mlt_id].blank?
    end

    # override to deal with A-Z link result display
    def render_constraint_element(label, value, options = {})
      if value.match(/ssort:[A-Z]+\*/)
        label = t('blacklight.search.constraints.az_search')
        value = value.match(/[A-Z]+/)[0]
      end
      super
    end

    # override to add method to show constraint for 'more like this' search
    def render_constraints(localized_params = params)
      render_mlt_query(localized_params) + super
    end

    # Render the 'more like this' query constraints
    def render_mlt_query(localized_params = params)
      # So simple don't need a view template, we can just do it here.
      scope = localized_params.delete(:route_set) || self
      return ''.html_safe if localized_params[:mlt_id].blank?

      render_constraint_element(t('blacklight.more_like_this.constraint_label'),
                                localized_params[:mlt_id],
                                :classes => ['mlt'],
                                :remove => scope.url_for(localized_params.merge(:mlt_id=>nil, :qt=>nil, :action=>'index')))
    end

    # include render_search_to_s_mlt() in rendered constraints
    # Simpler textual version of constraints, used on Search History page.
    def render_search_to_s(params)
      render_search_to_s_mlt(params) + super
    end

    # render the MLT search query constraint, used on Search History page.
    def render_search_to_s_mlt(params)
      return "".html_safe if params[:mlt_id].blank?
      render_search_to_s_element(t('blacklight.more_like_this.constraint_label'), render_filter_value(params[:mlt_id]) )
    end

  end
end