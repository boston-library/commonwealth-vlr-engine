module CommonwealthVlrEngine
  module LayoutHelper
    include Blacklight::LayoutHelperBehavior


    def show_content_classes
      "col-sm-12 show-document"
    end

    def show_sidebar_classes
      'col-sm-4'
    end
  end
end
