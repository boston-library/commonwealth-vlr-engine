# use to render new image in multi image viewer in catalog#show
class IiifManifestController < CatalogController

  include CommonwealthVlrEngine::CatalogHelper
  include IIIF::Presentation

  def manifest
    response, document = fetch(params[:id])
    image_files = has_image_files?(get_files(params[:id]))
    if image_files
      iiif_manifest = create_iiif_manifest(document, image_files)
      render :json => iiif_manifest.to_json
    else
      not_found
    end
  end

  def canvas
    canvas_response, canvas_document = fetch(params[:canvas_object_id])
    if canvas_document[:is_file_of_ssim]
      response, document = fetch(params[:id])
      image_files = has_image_files?(get_files(params[:id]))
      if image_files
        image_index = Hash[image_files.map.with_index.to_a][params[:canvas_object_id]]
        iiif_canvas = canvas_from_id(params[:canvas_object_id],
                                     "image#{(image_index+1).to_s}",
                                     document)
        render :json => iiif_canvas.to_json
      else
        not_found
      end
    else
      not_found
    end
  end

  def annotation
    response, document = fetch(params[:id])
    if has_image_files?(get_files(params[:id])).include?(params[:annotation_object_id])
      annotation = image_annotation_from_image_id(params[:annotation_object_id], document)
      render :json => annotation.to_json
    else
      not_found
    end
  end

  after_action :set_access_control_headers, :only => [:manifest, :canvas, :annotation]

  private

  # to allow apps to load manifest JSON received from a remote server
  def set_access_control_headers
    headers['Access-Control-Allow-Origin'] = "*"
  end

  def create_iiif_manifest(document, image_files)
    manifest = IIIF::Presentation::Manifest.new('@id' => "#{document[:identifier_uri_ss]}/manifest")
    manifest.label = document[blacklight_config.index.title_field.to_sym]
    manifest.viewing_hint = image_files.length > 1 ? 'paged' : 'individuals'
    manifest.metadata = manifest_metadata(document)
    manifest.description = document[:abstract_tsim].first if document[:abstract_tsim]

    attribution_array = []
    [:rights_ssm, :license_ssm, :restrictions_on_access_ssm].each do |field|
      attribution_array = attribution_array + document[field].presence.to_a
    end
    manifest.attribution = attribution_array.join(' ') unless attribution_array.blank?

    if document[:license_ssm]
      document[:license_ssm].each do |license|
        if license.match(/\(CC\s/)
          manifest.license = cc_url(license)
        end
      end
    end

    manifest.see_also = document[:identifier_uri_ss] if document[:identifier_uri_ss]

    sequence = IIIF::Presentation::Sequence.new
    image_files.each_with_index do |image, index|
      sequence.canvases << canvas_from_id(image, "image#{(index+1).to_s}", document)
    end
    manifest.sequences << sequence

    manifest_thumb_svc = manifest.sequences.first.canvases.first.images.first.resource.service
    manifest_thumb_svc['@id'] = manifest_thumb_svc['@id'].gsub(/[\-:\w]+\z/,document[:exemplary_image_ssi]) if document[:exemplary_image_ssi]
    manifest.insert_after(existing_key: 'label',
                          new_key: 'thumbnail',
                          value: {'@id' => "#{document[:identifier_uri_ss]}/thumbnail",
                                  'service' => manifest_thumb_svc})

    manifest
  end

  # image_id = id of image object
  # document = Solr doc of parent object
  def canvas_from_id(image_id, label, document)
    image_id_suffix = image_id.gsub(/\A[\w-]+:/,'/')
    annotation = image_annotation_from_image_id(image_id, document)
    canvas = IIIF::Presentation::Canvas.new('@id' => "#{document[:identifier_uri_ss]}/canvas#{image_id_suffix}")
    canvas.label = label
    canvas.thumbnail = document[:identifier_uri_ss].gsub(/\/[\w]+\z/, image_id_suffix) + "/thumbnail"
    canvas.width = annotation.resource['width']
    canvas.height = annotation.resource['height']
    canvas.images << annotation
    canvas
  end

  # create an Annotation
  # image_id = id of image object
  # document = Solr doc of parent object
  def image_annotation_from_image_id(image_id, document)
    image_id_suffix = image_id.gsub(/\A[\w-]+:/,'/')
    annotation = IIIF::Presentation::Annotation.new('@id' => "#{document[:identifier_uri_ss]}/annotation#{image_id_suffix}")
    annotation.resource = image_resource_from_image_id(image_id, document)
    annotation['on'] = "#{document[:identifier_uri_ss]}/canvas#{image_id_suffix}"
    annotation
  end

  def image_resource_from_image_id(page_id, document)
    base_uri = "#{IIIF_SERVER['url']}#{page_id}"
    params = {service_id: base_uri,
              resource_id: document[:identifier_uri_ss].gsub(/\/[\w]+\z/, page_id.gsub(/\A[\w-]+:/,'/')) + "/large_image"}
    image_resource = IIIF::Presentation::ImageResource.create_image_api_image_resource(params)
    image_resource
  end

  # returns a basic Dublin Core metadata set array
  def manifest_metadata(document)
    manifest_metadata = []
    manifest_metadata << {label: t('blacklight.metadata_display.fields.title'), value: document[blacklight_config.index.title_field.to_sym]}
    manifest_metadata << {label: t('blacklight.metadata_display.fields.date'), value: render_mods_dates(document).first} if document[:date_start_tsim]

    if document[:name_personal_tsim] || document[:name_corporate_tsim] || document[:name_generic_tsim]
      names = setup_names_roles(document).first
      manifest_metadata << {label: t('blacklight.metadata_display.fields.creator'), value: names.length == 1 ? names.first : names}
    end

    if document[:publisher_tsim]
      pubplace = document[:pubplace_tsim] ? document[:pubplace_tsim].first + ' : ' : ''
      manifest_metadata << {label: t('blacklight.metadata_display.fields.publisher'), value: pubplace + document[:publisher_tsim].first}
    end

    some_fields = {
        :type_of_resource_ssim => t('blacklight.metadata_display.fields.type_of_resource'),
        :genre_basic_ssim => t('blacklight.metadata_display.fields.genre_basic'),
        :abstract_tsim => t('blacklight.metadata_display.fields.abstract'),
        :lang_term_ssim => t('blacklight.metadata_display.fields.language'),
        :subject_facet_ssim => t('blacklight.metadata_display.fields.subject_topic'),
        :physical_location_ssim => t('blacklight.metadata_display.fields.location'),
        :related_item_host_ssim => t('blacklight.metadata_display.fields.collection')
    }
    some_fields.each do |k,v|
      values = document[k]
      manifest_metadata << {label: v, value: values.length == 1 ? values.first : values} if values
    end

    if document[:identifier_uri_ss]
      identifiers = [document[:identifier_uri_ss]]
      [:identifier_local_other_tsim, :identifier_local_call_tsim, :identifier_local_barcode_tsim, :identifier_isbn_tsim, :local_accession_id_tsim].each do |k|
        identifiers = identifiers + document[k] if document[k]
      end
      manifest_metadata << {label: t('blacklight.metadata_display.fields.id_local_other'), value: identifiers.length == 1 ? identifiers.first : identifiers}
    end

    if document[:rights_ssm]
      rights = document[:rights_ssm] + document[:license_ssm].presence.to_a
      manifest_metadata << {label: t('blacklight.metadata_display.fields.rights'), value: rights}
    end

    manifest_metadata
  end

  def not_found
    raise ActionController::RoutingError.new('Not Found')
  end


end