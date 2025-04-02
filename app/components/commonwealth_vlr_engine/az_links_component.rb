# frozen_string_literal: true

module CommonwealthVlrEngine
  class AzLinksComponent < ViewComponent::Base
    attr_reader :context

    def initialize(context:)
      @context = context
    end

    def az_exclude
      context == 'institutions' ? %w[V X Z] : []
    end

    def az_label
      I18n.t("blacklight.#{context}.index.a-z_label")
    end

    def az_link_path
      "#{context}_path"
    end

    def link_to_az_value(letter)
      new_params = params.permit!.except(:controller, :action, :q, :page)
      new_params[:q] = "#{CommonwealthVlrEngine::ControllerOverride::TITLE_SORT.split.first}:#{letter}*"
      link_to(letter, self.send(az_link_path, new_params), class: 'az_link')
    end
  end
end
