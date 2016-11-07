module CommonwealthVlrEngine
  module SearchHistoryConstraintsHelper
    include Blacklight::SearchHistoryConstraintsHelperBehavior

    # include render_search_to_s_mlt() in rendered constraints
    def render_search_to_s(params)
      render_search_to_s_advanced(params) + render_search_to_s_mlt(params) + super
    end

    # render the MLT search query constraint, used on Search History page.
    def render_search_to_s_mlt(params)
      return "".html_safe if params[:mlt_id].blank?
      render_search_to_s_element(t('blacklight.more_like_this.constraint_label'),
                                 render_filter_value(params[:mlt_id]))
    end

    # render advanced search date constraints, used on SearchHistory, etc.
    def render_search_to_s_advanced(params)
      return "".html_safe if params[:date_start].blank? && params[:date_end].blank?
      render_search_to_s_element(t('blacklight.advanced_search.constraints.date'),
                                 render_filter_value(date_range_constraints_to_s(params)))
    end

  end
end