# frozen_string_literal: true

module CommonwealthVlrEngine
  class OcrDocumentComponent < Blacklight::DocumentComponent
    def initialize(document: nil, presenter: nil, partials: nil,
                   id: nil, classes: [], component: :article, title_component: nil,
                   counter: nil, document_counter: nil, counter_offset: 0,
                   show: false, **args)
      @image_pid_list = args[:image_pid_list]
      @parent_ark_id = args[:parent_ark_id]
      @ocr_q = args[:ocr_q]
      super
    end

    def blacklight_config
      @presenter.configuration
    end

    def snippets
      @presenter.field_value(blacklight_config.index_fields[blacklight_config.ocr_search_field],
                             { counter: helpers.document_counter_with_offset(document_counter) })
    end

    def ocr_term_frequency
      pluralize(compute_term_freq, I18n.t('blacklight.ocr.search.results.term_freq.start'))
    end

    # return the term frequency as an integer
    # if Solr returns 0, change to 1 (most likely phrase search)
    def compute_term_freq
      term_freq = @document[:term_freq].to_i
      term_freq > 0 ? term_freq : term_freq + 1
    end

    # link to catalog#show with params for the image viewer, using page number or image index
    def page_link
      index_of_doc = @image_pid_list.index(@document.id)
      page_num = @document[blacklight_config.page_num_field.to_sym]
      viewer_path = "#{solr_document_path(@parent_ark_id)}#?&cv=#{index_of_doc}"
      viewer_path += "&h=#{url_encode(@ocr_q)}" if @ocr_q.present?
      link_to(page_num ? "Page #{page_num}" : "Image #{index_of_doc + 1}",
              viewer_path, class: 'page_link', rel: 'nofollow')
    end
  end
end
