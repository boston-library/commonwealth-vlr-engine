# frozen_string_literal: true

module CommonwealthVlrEngine
  class BreadcrumbComponent < Blacklight::Component
    def initialize(document: nil, link_class: nil)
      @document = document
    end

    attr_reader :document, :link_class

    def render_item_breadcrumb
      separator = icon('fas', 'arrow-right', class: 'breadcrumb_separator', aria: { hidden: true })
      breadcrumbs = [institution_link, collection_links]
      breadcrumbs.join(separator).html_safe
    end

    def institution_link
      return unless document[:institution_ark_id_ssi].present?

      link_to(document[helpers.blacklight_config.institution_field.to_sym],
              institution_path(id: document[:institution_ark_id_ssi]),
              id: 'institution_breadcrumb')
    end

    def collection_links
      helpers.setup_collection_links(document, link_class).sort.join(' / ').html_safe
    end

    def render?
      document[:institution_ark_id_ssi].present? || document[:collection_ark_id_ssim].present?
    end
  end
end
