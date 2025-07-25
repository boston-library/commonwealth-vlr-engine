# frozen_string_literal: true

module CommonwealthVlrEngine
  module OcrSearchHelperBehavior
    # if current_search_session exists, return query_params['q'], otherwise return nil
    # @current_search_session is defined in Blacklight::SearchContext
    def ocr_q_params(current_search_session)
      current_search_session ? current_search_session.query_params['q'] : nil
    end

    # print the ocr snippets. if more than one, separate with <br/>
    def render_ocr_snippets(options = {})
      snippets = options[:value]
      snippets_content = [content_tag('div',
                                      "... #{snippets.first} ...".html_safe,
                                      class: 'ocr_snippet first_snippet')]
      if snippets.length > 1
        snippets_content << render(partial: 'ocr_search/snippets_more',
                                   locals: { snippets: snippets.drop(1),
                                             counter: options[:counter] })
      end
      snippets_content.join("\n").html_safe
    end
  end
end
