# frozen_string_literal: true

module CommonwealthVlrEngine
  module LayoutHelper
    include Blacklight::LayoutHelperBehavior
    # Classes added to a document's show content div
    # @return [String]
    def show_content_classes
      'col-sm-12 show-document'
    end

    # def show_sidebar_classes
    #   'col-sm-4'
    # end

    # don't think this is needed? There's no CSS for blacklight-home
    # def extra_body_classes
    #   @extra_body_classes ||= ['blacklight-' + controller_name, 'blacklight-' + [controller_name, controller.action_name].join('-')]
    #   # if this is the home page
    #   if controller_name == 'pages' && action_name == 'home'
    #     @extra_body_classes.push('blacklight-home')
    #   else
    #     @extra_body_classes
    #   end
    # end

    # override and return nil, since these links just return empty XML documents
    # TODO: figure out how to include JSON as an @rel='alternate' link, like in catalog#index
    # def render_link_rel_alternates(_document = @document, _options = {})
    #   nil
    # end
  end
end
