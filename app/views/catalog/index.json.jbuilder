# frozen_string_literal: true

json.links do
  json.self url_for(search_state.to_h.merge(only_path: false))
  json.prev url_for(search_state.to_h.merge(only_path: false, page: @response.prev_page.to_s)) if @response.prev_page
  json.next url_for(search_state.to_h.merge(only_path: false, page: @response.next_page.to_s)) if @response.next_page
  json.last url_for(search_state.to_h.merge(only_path: false, page: @response.total_pages.to_s))
end

json.meta do
  json.pages @presenter.pagination_info
end

json.data do
  json.array! @presenter.documents do |document|
    doc_presenter = document_presenter(document)
    document_url = Deprecation.silence(Blacklight::UrlHelperBehavior) { polymorphic_url(url_for_document(document)) }
    json.id document.id
    json.type doc_presenter.display_type.first
    json.attributes do
      fields_to_render = doc_presenter.fields_to_render.reject { |field_name, _, _| field_name == 'mods_xml_ss' }
      fields_to_render.each do |field_name, field, field_presenter|
        json.partial! 'field', field: field,
                               field_name: field_name,
                               document_url: document_url,
                               doc_presenter: doc_presenter,
                               field_presenter: field_presenter,
                               view_type: 'index'
      end
    end

    json.links do
      json.self document_url
    end
  end
end
