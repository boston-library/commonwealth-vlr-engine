module CommonwealthVlrEngine
  module LayoutHelper
    include Blacklight::LayoutHelperBehavior

    def main_content_classes
      'col-sm-9'
    end

    def show_content_classes
      'col-sm-12 show-document'
    end

    def show_sidebar_classes
      'col-sm-4'
    end

    def sidebar_classes
      'col-sm-3'
    end

  end
end
