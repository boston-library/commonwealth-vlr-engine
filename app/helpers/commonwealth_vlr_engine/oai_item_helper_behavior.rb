# frozen_string_literal: true

module CommonwealthVlrEngine
  module OaiItemHelperBehavior
    # return the correct name of the institution to link to for OAI objects
    def oai_inst_name(document)
      if document[blacklight_config.institution_field.to_sym]
        document[blacklight_config.institution_field.to_sym].first
      else
        t('blacklight.oai_objects.default_inst_name')
      end
    end

    # return the text for a link to an OAI item
    def oai_link_text(document)
      if document[:type_of_resource_ssim]
        types = document[:type_of_resource_ssim].join(' ')
        if types.match?(/text/)
          t('blacklight.oai_objects.link_to_item.generic', institution_name: oai_inst_name(document))
        elsif types.match?(/carto/)
          t('blacklight.oai_objects.link_to_item.map', institution_name: oai_inst_name(document))
        elsif types.match?(/sound/)
          t('blacklight.oai_objects.link_to_item.sound', institution_name: oai_inst_name(document))
        elsif types.match?(/moving/)
          t('blacklight.oai_objects.link_to_item.video', institution_name: oai_inst_name(document))
        elsif types.match?(/still/)
          t('blacklight.oai_objects.link_to_item.image', institution_name: oai_inst_name(document))
        else
          t('blacklight.oai_objects.link_to_item.generic', institution_name: oai_inst_name(document))
        end
      else
        t('blacklight.oai_objects.link_to_item.generic', institution_name: oai_inst_name(document))
      end
    end
  end
end
