# frozen_string_literal: true

module CommonwealthVlrEngine
  class MltItemPresenter < Blacklight::FacetItemPresenter
    # TODO: do we need this?
    def value
      super.to_param
    end
  end
end
