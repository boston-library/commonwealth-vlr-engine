# frozen_string_literal: true

# basically a copy of Blacklight::HeaderComponent,
# but we remove SearchNavbarComponent, and call a custom TopNavbarComponent
module CommonwealthVlrEngine
  class HeaderComponent < Blacklight::Component
    renders_one :top_bar, lambda { |component: CommonwealthVlrEngine::TopNavbarComponent|
      component.new(blacklight_config: blacklight_config)
    }

    def initialize(blacklight_config:)
      @blacklight_config = blacklight_config
    end

    attr_reader :blacklight_config

    # Hack so that the default lambdas are triggered
    # so that we don't have to do c.with_top_bar() in the call.
    def before_render
      with_top_bar unless top_bar
    end
  end
end
