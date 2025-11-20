# frozen_string_literal: true

# define our own class so we can override Blacklight::SearchState#url_for_document
module CommonwealthVlrEngine
  class SearchState < Blacklight::SearchState
    def url_for_document(doc, _options = {})
      return super if doc.blank?

      case doc[blacklight_config.show.display_type_field]
      when 'Collection', 'Institution'
        { controller: doc[blacklight_config.show.display_type_field].downcase.pluralize, action: :show, id: doc }
      else
        doc
      end
    end
  end
end
