# frozen_string_literal: true

module CommonwealthVlrEngine
  module Document
    class HarvestedItemComponent < ViewComponent::Base
      def initialize(document:)
        @document = document
      end
      attr_reader :document

      # return the text for a link to an OAI item
      def oai_link_text
        if document[:type_of_resource_ssim]
          types = document[:type_of_resource_ssim].join(' ')
          key = if types.match?(/Text/)
                  'generic'
                elsif types.match?(/Carto/)
                  'map'
                elsif types.match?(/Audio/)
                  'audio'
                elsif types.match?(/Moving/)
                  'video'
                elsif types.match?(/Still/)
                  'image'
                else
                  'generic'
                end
        else
          key = 'generic'
        end
        I18n.t("blacklight.oai_objects.link_to_item.#{key}", institution_name: helpers.oai_inst_name(document))
      end

      def render?
        helpers.harvested_object?(document)
      end
    end
  end
end
