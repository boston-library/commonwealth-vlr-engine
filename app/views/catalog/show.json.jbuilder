# frozen_string_literal: true

document_url = polymorphic_url(@document)
doc_presenter = document_presenter(@document)
json.foo doc_presenter.class.to_s

json.links do
  json.self document_url
end

json.data do
  json.id @document.id
  json.type doc_presenter.display_type.first
  json.attributes do
    json.title doc_presenter.heading unless doc_presenter.fields_to_render.any? { |field_name, _field, _field_presenter| field_name.to_s == 'title' }

    doc_presenter.fields_to_render.each do |field_name, field, field_presenter|
      json.partial! 'field', field: field,
                    field_name: field_name,
                    document_url: document_url,
                    doc_presenter: doc_presenter,
                    field_presenter: field_presenter,
                    view_type: 'show'
    end
  end
end