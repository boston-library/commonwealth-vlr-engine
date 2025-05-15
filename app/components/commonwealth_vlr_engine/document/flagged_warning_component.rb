# frozen_string_literal: true

module CommonwealthVlrEngine
  module Document
    class FlaggedWarningComponent < ViewComponent::Base
      def initialize(document:)
        @document = document
      end
      attr_reader :document

      def flagged_warning
        send("#{flag_type}_warning".to_sym)
      end

      def explicit_warning
        render 'catalog/flagged_modal'
      end

      def offensive_warning
        content_tag :div, id: 'flagged_content_warning', class: 'alert alert-warning' do
          I18n.t('blacklight.flagged.offensive.body')
        end
      end

      def flag_type
        document[helpers.blacklight_config.flagged_field]
      end

      def render?
        flag_type.present?
      end
    end
  end
end
