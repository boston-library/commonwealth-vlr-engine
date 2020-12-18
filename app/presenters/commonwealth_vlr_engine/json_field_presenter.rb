# frozen_string_literal: true

module CommonwealthVlrEngine
  class JsonFieldPresenter < Blacklight::FieldPresenter
    private

    def retrieve_values
      document[field_config.field]
    end
  end
end
