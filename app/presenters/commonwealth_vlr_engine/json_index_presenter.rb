# frozen_string_literal: true

module CommonwealthVlrEngine
  class JsonIndexPresenter < Blacklight::IndexPresenter
    private

    # override Blacklight::IndexPresenter so we can make all Solr fields available to #fields_to_render
    # @return [Hash<String,Configuration::Field>] all the fields for this index view
    def fields
      Hash[document.keys.collect { |k| [k, Blacklight::Configuration::NullDisplayField.new(k)] }]
    end

    # override so we can set custom field presenter
    def field_presenter(field_config, options = {})
      presenter_class = CommonwealthVlrEngine::JsonFieldPresenter
      presenter_class.new(view_context, document, field_config, field_presenter_options.merge(options))
    end
  end
end
