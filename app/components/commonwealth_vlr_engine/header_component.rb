# frozen_string_literal: true

# subclass so we can render custom header
module CommonwealthVlrEngine
  class HeaderComponent < Blacklight::HeaderComponent
    # Hack so that the default lambdas are triggered
    # so that we don't have to do c.with_top_bar() in the call.
    def before_render
      set_slot(:top_bar, nil) unless top_bar
      # set_slot(:search_bar, nil) unless search_bar
    end
  end
end
