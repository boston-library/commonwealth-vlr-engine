module CommonwealthVlrEngine
  module OcrSearchHelperBehavior

    # link to the book viewer, using page number or image index
    # @document = SolrDocument
    # @image_pid_list = an ordered Array of image pids for the book object
    # @book_id = pid of book object
    def render_page_link(document, image_pid_list, book_id)
      index_of_doc = image_pid_list.index(document.id)
      page_num = document[blacklight_config.page_num_field.to_sym]
      if page_num
        link_title = "Page #{page_num}"
      else
        link_title = "Image #{index_of_doc+1} of #{image_pid_list.count}"
      end
      link_to link_title,
              "#{book_viewer_path(book_id)}#1/#{index_of_doc+1}",
              :class => 'book_page_link',
              :rel => 'nofollow'
    end



  end
end