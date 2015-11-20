module CommonwealthVlrEngine
  module BlacklightHelper
    include Blacklight::BlacklightHelperBehavior

    # local override to allow using CommonwealthVlrEngine::CatalogHelper#render_main_title
    # for catalog#show title heading
    def document_heading document=nil
      document ||= @document
      if document[blacklight_config.index.title_field.to_sym]
        render_main_title(document)
      else
        @document.id
      end
    end

    # local override to use custom #document_heading method (above) for catalog#show title heading
    def render_document_heading(*args)
      options = args.extract_options!

      tag_or_document = args.first

      if tag_or_document.is_a? String or tag_or_document.is_a? Symbol
        Deprecation.warn(Blacklight::BlacklightHelperBehavior, "#render_document_heading with a tag argument is deprecated; pass e.g. `tag: :h4` instead")
        tag = tag_or_document
        document = @document
      else
        tag = options.fetch(:tag, :h4)
        document = tag_or_document || @document
      end

      content_tag(tag, document_heading(document), itemprop: "name")
    end

  end
end