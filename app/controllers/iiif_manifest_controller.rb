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
    manifest = IIIF::Presentation::Manifest.new('@id' => "#{catalog_index_url}/#{document[:id]}/manifest")
    manifest.label = document[blacklight_config.index.title_field.to_sym]
    manifest.viewing_hint = image_files.length > 1 ? 'paged' : 'individuals'
    manifest.metadata = manifest_metadata(document)
    manifest.description = document[:abstract_tsim].first if document[:abstract_tsim]
    manifest.attribution = document[:rights_ssm].first if document[:rights_ssm]
    manifest.license = document[:license_ssm].first if document[:license_ssm]
    manifest.see_also = document[:identifier_uri_ss] if document[:identifier_uri_ss]

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

  def manifest_metadata(document)
    manifest_metadata = []
    manifest_metadata << {'dc:title' => document[blacklight_config.index.title_field.to_sym]}
    manifest_metadata << {'dc:date' => render_mods_dates(document).first} if document[:date_start_tsim]
    #manifest_metadata << {'dc:abstract' => document[:abstract_tsim].first} if document[:abstract_tsim]

    if document[:name_personal_tsim] || document[:name_corporate_tsim] || document[:name_generic_tsim]
      names = setup_names_roles(document).first
      manifest_metadata << {'dc:creator' => names.length == 1 ? names.first : names}
    end

    if document[:type_of_resource_ssim]
      formats = document[:type_of_resource_ssim] + document[:genre_basic_ssim].presence.to_a
      manifest_metadata << {'dc:format' => formats }
    end

    if document[:publisher_tsim]
      pubplace = document[:pubplace_tsim] ? document[:pubplace_tsim].first + ' : ' : ''
      manifest_metadata << {'dc:publisher' => pubplace + document[:publisher_tsim].first }
    end

    {:lang_term_ssim => 'dc:language', :subject_facet_ssim => 'dc:subject', :physical_location_ssim => 'dc:source'}.each do |k,v|
      values = document[k]
      manifest_metadata << {v => values.length == 1 ? values.first : values}
    end

    #{ 'Foo' => 'Bar' }, { 'Baz' => [ 'Quux', 'Corge' ]}
    manifest_metadata
  end


end