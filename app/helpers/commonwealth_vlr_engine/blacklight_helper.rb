module CommonwealthVlrEngine
  module BlacklightHelper
    include Blacklight::BlacklightHelperBehavior

    # local override to use render_main_title for catalog#show title heading
    def document_heading document=nil
      document ||= @document
      if document[blacklight_config.index.title_field.to_sym]
        render_main_title(document)
      else
        @document.id
      end
    end

  end
end