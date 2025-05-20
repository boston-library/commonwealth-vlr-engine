# frozen_string_literal: true

module CommonwealthVlrEngine
  module OaiItemHelperBehavior
    # return the correct name of the institution to link to for OAI objects
    def oai_inst_name(document)
      document[blacklight_config.institution_field.to_sym] || t('blacklight.oai_objects.default_inst_name')
    end
  end
end
