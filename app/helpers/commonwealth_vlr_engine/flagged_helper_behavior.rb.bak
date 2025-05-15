# frozen_string_literal: true

module CommonwealthVlrEngine
  module FlaggedHelperBehavior
    # return the correct name of the institution to link to for OAI objects
    def show_explicit_warning?(document)
      document[blacklight_config.flagged_field.to_sym] == 'explicit'
    end

    # return the correct name of the institution to link to for OAI objects
    def show_content_warning?(document)
      document[blacklight_config.flagged_field.to_sym] == 'offensive'
    end
  end
end
