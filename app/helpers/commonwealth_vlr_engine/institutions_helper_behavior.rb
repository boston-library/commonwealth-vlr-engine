# frozen_string_literal: true

module CommonwealthVlrEngine
  module InstitutionsHelperBehavior
    # link to view all items from an institution
    def link_to_all_inst_items(link_class)
      link_to(t('blacklight.institutions.browse.all'),
              search_catalog_path(f: { blacklight_config.institution_field => [@institution_title] }),
              class: link_class)
    end
  end
end
