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

    # override to add methods to show constraints for 'more like this' and advanced search date range
    def render_constraints(localized_params = params)
      render_mlt_query(localized_params) + render_advanced_date_query(localized_params) + super
    end

    # Render the advanced search date query constraints
    def render_advanced_date_query(localized_params = params)
      # So simple don't need a view template, we can just do it here.
      return ''.html_safe if localized_params[:date_start].blank? && localized_params[:date_end].blank?

      date_constraint = if localized_params[:date_start].blank?
                          "before #{localized_params[:date_end]}"
                        elsif localized_params[:date_end].blank?
                          "after #{localized_params[:date_start]}"
                        else
                          "#{localized_params[:date_start]}-#{localized_params[:date_end]}"
                        end
      render_constraint_element(t('blacklight.advanced_search.constraints.date'),
                                date_constraint,
                                :classes => ['date_range'],
                                :remove => remove_constraint_url(localized_params.merge(date_start: nil,
                                                                                        date_end: nil,
                                                                                        :action=>'index')))
    end

    # Render the 'more like this' query constraints
    def render_mlt_query(localized_params = params)
      # So simple don't need a view template, we can just do it here.
      return ''.html_safe if localized_params[:mlt_id].blank?

      render_constraint_element(t('blacklight.more_like_this.constraint_label'),
                                localized_params[:mlt_id],
                                :classes => ['mlt'],
                                :remove => remove_constraint_url(localized_params.merge(:mlt_id=>nil,
                                                                                        :qt=>nil,
                                                                                        :action=>'index')))
    end

  end
end