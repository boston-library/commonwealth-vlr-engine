# frozen_string_literal: true

module CommonwealthVlrEngine
  module LayoutHelper
    include Blacklight::LayoutHelperBehavior
    # Classes added to a document's show content div
    # @return [String]
    def show_content_classes
      'col-sm-12 show-document'
    end

    def metadata_field_label_class(field_key: nil, classes: ['col-md-3'])
      classes << "metadata-field-label_#{field_key}" if field_key
      classes.join(' ')
    end

    def metadata_field_value_class(field_key: nil, classes: ['col-md-9'])
      classes << "metadata-field-value_#{field_key}" if field_key
      classes.join(' ')
    end
  end
end
