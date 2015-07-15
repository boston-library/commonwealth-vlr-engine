# use to render new image in multi image viewer in catalog#show
class IiifManifestController < CatalogController

  include CommonwealthVlrEngine::CatalogHelper
  include IIIF::Presentation

  def show
    response, document = fetch(params[:id])
    image_files = has_image_files?(get_files(params[:id]))
    iiif_manifest = create_iiif_manifest(document, image_files)
    render :json => iiif_manifest.to_json
    #respond_to do |format|
    #  format.json
    #end
  end

  def create_iiif_manifest(document, image_files)
    manifest = IIIF::Presentation::Manifest.new('@id' => 'http://example.org/my_book')
    manifest.label = document[blacklight_config.index.title_field.to_sym]
    manifest.viewing_hint = image_files.length > 1 ? 'paged' : 'individuals'
    manifest.metadata = [
        { 'Foo' => 'Bar' },
        { 'Baz' => [ 'Quux', 'Corge' ]}
    ]

    sequence = IIIF::Presentation::Sequence.new
    image_files.each_with_index do |image, index|
      sequence.canvases << image_annotation_from_id(image, (index+1).to_s)
    end

    manifest.sequences << sequence

    thumb = manifest.sequences.first.canvases.first.images.first.resource['@id']
    manifest.insert_after(existing_key: 'label', new_key: 'thumbnail', value: thumb)
    manifest
  end

  def image_annotation_from_id(image_id, label)
    annotation = IIIF::Presentation::Annotation.new
    annotation.resource = image_resource_from_page_hash(image_id)
    canvas = IIIF::Presentation::Canvas.new
    canvas_uri = "http://example.org/my_book/pages/#{image_id}"
    canvas['@id'] = canvas_uri
    canvas.label = label
    canvas.width = annotation.resource['width']
    canvas.height = annotation.resource['height']
    canvas.images << annotation
    canvas
  end

  def image_resource_from_page_hash(page_id)
    base_uri = "#{IIIF_SERVER['url']}#{page_id}"
    params = {service_id: base_uri}
    image_resource = IIIF::Presentation::ImageResource.create_image_api_image_resource(params)
    image_resource
  end


end