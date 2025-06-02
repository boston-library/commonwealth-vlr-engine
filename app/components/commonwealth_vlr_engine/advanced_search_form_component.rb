# frozen_string_literal: true

module CommonwealthVlrEngine
  class AdvancedSearchFormComponent < Blacklight::AdvancedSearchFormComponent

    def sort_fields_select
      false
    end

    private

    def initialize_search_field_controls
      search_fields.values.take(4).each.with_index do |field, i|
        next if field.key == blacklight_config.full_text_index

        with_search_field_control do
          content_tag(:div, class: 'advanced-search-field row') do
            select_tag("clause[#{i}][field]",
                       options_for_select(search_fields.values.map { |sf| [sf.label, sf.key] }, search_fields.keys[i]),
                       title: t('blacklight.search.basic_search.form.search_indexes'),
                       class: 'btn btn-outline-secondary search_index_select col-sm-3 col-md-3 col-lg-5 col-xl-4 col-form-label') +
              label_tag("clause_#{i}_query",
                        t('blacklight.search.basic_search.form.q') + ' (' + (i + 1).to_s + ')',
                        class: 'visually-hidden') +
              content_tag(:div, class: 'col-sm-8 col-md-8 col-lg-7 col-xl-8 advanced-search-input-wrapper') do
                text_field_tag("clause[#{i}][query]", nil,
                               class: 'advanced_input_text form-control',
                               autofocus: i == 0 ? true : false)
              end
          end
        end
      end
    end
  end
end
