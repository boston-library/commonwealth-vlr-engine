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

  end
end