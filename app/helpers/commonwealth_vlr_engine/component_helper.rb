module CommonwealthVlrEngine

  module ComponentHelper
    include Blacklight::ComponentHelperBehavior

    # add extra tools to show view -- folders, social sharing, etc.
    def render_show_doc_actions(document=@document, options={})
      wrapping_class = options.delete(:documentFunctions) || options.delete(:wrapping_class) || 'documentFunctions'
      content = []
      #content << render(:partial => 'catalog/bookmark_control', :locals => {:document=> document}.merge(options)) if render_bookmarks_control?

      # social media:
      content << render(:partial => 'catalog/add_this')
      if has_user_authentication_provider? and current_or_guest_user
        content << render(:partial => 'catalog/folder_item_control', :locals => {:document => document})
      end
      content_tag('div', content.join("\n").html_safe, :class=> wrapping_class)
    end

  end

end
