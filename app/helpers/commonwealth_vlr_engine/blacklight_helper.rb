module CommonwealthVlrEngine
  module BlacklightHelper
    include Blacklight::BlacklightHelperBehavior

    # local override to allow using CommonwealthVlrEngine::CatalogHelper#render_full_title
    # for catalog#show title heading
    def document_heading document=nil
      document ||= @document
      if document[blacklight_config.index.title_field.to_sym]
        render_full_title(document)
      else
        @document.id
      end
    end

    # local override to use custom #document_heading method (above) for catalog#show title heading
    def render_document_heading(*args)
      options = args.extract_options!
      document = args.first
      tag = options.fetch(:tag, :h4)
      document = document || @document

      content_tag(tag, document_heading(document), itemprop: "name")
    end

  end
end
