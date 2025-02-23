# frozen_string_literal: true

module CommonwealthVlrEngine
  class JsonFieldPresenter < Blacklight::FieldPresenter
    private

    # override to simplify rendering values
    def retrieve_values
      document[field_config.field]
    end
  end
end
