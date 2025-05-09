# frozen_string_literal: true

# subclass so we can override a few methods
module CommonwealthVlrEngine
  module System
    class DropdownComponent < Blacklight::System::DropdownComponent
      def render?
        @choices.any?
      end
    end
  end
end
