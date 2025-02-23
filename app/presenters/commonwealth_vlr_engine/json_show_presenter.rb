# frozen_string_literal: true

module CommonwealthVlrEngine
  class JsonShowPresenter < Blacklight::ShowPresenter
    # override Blacklight::DocumentPresenter needed so we return value as array
    # since CommonwealthVlrEngine::JsonFieldPresenter#retrieve_values returns String
    # (app/view/catalog/index.json.builder calls display_type.first)
    def display_type(base_name = nil, default: nil)
      [super]
    end

    private

    # override Blacklight::IndexPresenter so we can make all Solr fields available to #fields_to_render
    # @return [Hash<String,Configuration::Field>] all the fields for this index view
    def fields
      Hash[document.keys.collect { |k| [k, Blacklight::Configuration::NullDisplayField.new(k)] }]
    end

    # override so we can set custom presenter
    # def field_presenter(field_config, options = {})
    #   presenter_class = CommonwealthVlrEngine::JsonFieldPresenter
    #   presenter_class.new(view_context, document, field_config, field_presenter_options.merge(options))
    # end
  end
end
