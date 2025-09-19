# frozen_string_literal: true

module CommonwealthVlrEngine
  module LayoutHelper
    include Blacklight::LayoutHelperBehavior
    # Classes added to a document's show content div
    # @return [String]
    def show_content_classes
      'col-sm-12 show-document'
    end

    def metadata_field_label_class
      'col-md-3'
    end

    def metadata_field_value_class
      'col-md-9'
    end
  end
end
