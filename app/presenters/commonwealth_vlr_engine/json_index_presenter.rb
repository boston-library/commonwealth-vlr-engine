# frozen_string_literal: true

module CommonwealthVlrEngine
  class JsonIndexPresenter < Blacklight::IndexPresenter
    # override Blacklight::DocumentPresenter needed so we return value as array
    # since CommonwealthVlrEngine::JsonFieldPresenter#retrieve_values returns String
    # (app/view/catalog/index.json.builder calls display_type.first)
    def display_type(base_name = nil, default: nil)
      [super]
    end

    private

    # override Blacklight::IndexPresenter so we can return all Solr fields
    # @return [Hash<String,Configuration::Field>] all the fields for this index view
    def fields
      #Hash[document.keys.collect { |k| [k, field_config(k)] } ]
      field_return = @fields ||= Array(display_type).inject(display_fields) do |fields, display_type|
        fields.merge(display_fields(configuration.for_display_type(display_type)))
      end
      puts "FIELD RETURN: #{field_return}"
      puts "FIELD RETURN CLASS: #{field_return.class}"
      field_return
    end

    # override so we can set custom presenter
    def field_presenter(field_config, options = {})
      presenter_class = CommonwealthVlrEngine::JsonFieldPresenter
      presenter_class.new(view_context, document, field_config, field_presenter_options.merge(options))
    end
  end
end
