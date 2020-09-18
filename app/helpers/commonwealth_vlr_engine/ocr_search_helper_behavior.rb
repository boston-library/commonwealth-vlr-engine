module CommonwealthVlrEngine
  module OcrSearchHelperBehavior

    # return the term frequency as an integer
    # if Solr returns 0, change to 1 (most likely phrase search)
    def compute_term_freq(term_freq)
      term_freq > 0 ? term_freq : term_freq+1
    end

    # determine of the item has text content that can be searched
    def has_searchable_text?(document)
      document['has_searchable_text_bsi']
    end

    # if current_search_session exists, return query_params['q'], otherwise return nil
    # @current_search_session is defined in Blacklight::SearchContext
    def ocr_q_params(current_search_session)
      if current_search_session
        current_search_session.query_params['q']
      else
        nil
      end
    end

    # print the ocr snippets. if more than one, separate with <br/>
    def render_ocr_snippets options={}
      snippets = options[:value]
      snippets_content = [content_tag('div',
                                      "... #{snippets.first} ...".html_safe,
                                      class: 'ocr_snippet first_snippet')]
      if snippets.length > 1
        snippets_content << render(partial: 'ocr_search/snippets_more',
                                   locals: {snippets: snippets.drop(1),
                                            counter: options[:counter]})
      end
      snippets_content.join("\n").html_safe
    end

    # link to the book viewer, using page number or image index
    # @document = SolrDocument (page object)
    # @image_pid_list = an ordered Array of image pids for the book object
    # @book_id = pid of book object
    def render_page_link(document, image_pid_list, book_id)
      index_of_doc = image_pid_list.index(document.id)
      page_num = document[blacklight_config.page_num_field.to_sym]
      # TODO: UV doesn't seem to allow passing query string, as in "h=#{url_encode(params[:ocr_q])}"
      link_to page_num ? "Page #{page_num}" : "Image #{index_of_doc + 1}",
              "#{book_viewer_path(book_id)}#?&cv=#{index_of_doc}",
              class: 'book_page_link',
              rel: 'nofollow'
    end
  end
end
