# frozen_string_literal: true

module CommonwealthVlrEngine
  class BreadcrumbComponent < Blacklight::Component
    def initialize(document: nil)
      @document = document
    end

    attr_reader :document
  end
end
