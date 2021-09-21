# frozen_string_literal: true

# methods used to create IIIF Presentation API manifest
module CommonwealthVlrEngine
  module IiifManifest
    extend ActiveSupport::Concern

    include IIIF::Presentation

    # create an IIIF manifest
    # document = SolrDocument
    # image_files = an array of ImageFile Solr documents
    def create_iiif_manifest(document, image_files)
      manifest = IIIF::Presentation::Manifest.new('@id' => "#{document[:identifier_uri_ss]}/manifest")
      manifest.service = iiif_search_service(document) if document[:has_searchable_pages_bsi]
      manifest.label = render_title(document, false)
      manifest.viewing_hint = image_files.length > 1 ? 'paged' : 'individuals'
      manifest.metadata = manifest_metadata(document)
      manifest.description = document[:abstract_tsi] if document[:abstract_tsi]

      manifest.attribution = manifest_attribution(document).presence

      if document[:license_ss]
        manifest.license = cc_url(document[:license_ss]) if document[:license_ss].match?(/\(CC\s/)
      end

      manifest.see_also = document[:identifier_uri_ss] if document[:identifier_uri_ss]

      sequence = IIIF::Presentation::Sequence.new
      image_files.each_with_index do |image, index|
        sequence.canvases << canvas_from_id(image.id, label_for_canvas(image, index), document)
      end
      manifest.sequences << sequence

      manifest_thumb_svc = manifest.sequences.first.canvases.first.images.first.resource.service
      manifest_thumb_svc['@id'] = manifest_thumb_svc['@id'].gsub(/[\-:\w]+\z/, document[:exemplary_image_ssi]) if document[:exemplary_image_ssi]
      manifest.insert_after(existing_key: 'label',
                            new_key: 'thumbnail',
                            value: { '@id' => "#{document[:identifier_uri_ss]}/thumbnail",
                                     'service' => manifest_thumb_svc })

      manifest
    end

    # create an IIIF canvas
    # image_id = id of image object
    # label = the label property of the canvas
    # document = Solr doc of parent object
    def canvas_from_id(image_id, label, document)
      image_id_suffix = image_id.gsub(/\A[\w-]+:/, '/')
      annotation = image_annotation_from_image_id(image_id, document)
      canvas = IIIF::Presentation::Canvas.new('@id' => "#{document[:identifier_uri_ss]}/canvas#{image_id_suffix}")
      canvas.label = label
      canvas.width = annotation.resource['width']
      canvas.height = annotation.resource['height']
      canvas.images << annotation
      # Mirador has a bug where Canvas thumbnails crash the viewer
      # https://github.com/ProjectMirador/mirador/issues/1452
      # uncomment below if this gets fixed at some point
      # canvas_thumb_svc = canvas.images.first.resource.service
      # canvas.thumbnail = {'@id' => document[:identifier_uri_ss].gsub(/\/[\w]+\z/, image_id_suffix) + "/thumbnail",
      #                     'service' => canvas_thumb_svc}
      canvas
    end

    # create an IIIF Annotation
    # image_id = id of image object
    # document = Solr doc of parent object
    def image_annotation_from_image_id(image_id, document)
      image_id_suffix = image_id.gsub(/\A[\w-]+:/, '/')
      annotation = IIIF::Presentation::Annotation.new('@id' => "#{document[:identifier_uri_ss]}/annotation#{image_id_suffix}")
      annotation.resource = image_resource_from_image_id(image_id, document)
      annotation['on'] = "#{document[:identifier_uri_ss]}/canvas#{image_id_suffix}"
      annotation
    end

    # return an IIIF image resource
    # page_id = id of image object
    # document = SolrDocument of parent object
    def image_resource_from_image_id(page_id, document)
      base_uri = "#{IIIF_SERVER['url']}#{page_id}"
      params = { service_id: base_uri,
                 resource_id: document[:identifier_uri_ss].gsub(/\/[\w]+\z/, page_id.gsub(/\A[\w-]+:/, '/')) + '/large_image' }
      IIIF::Presentation::ImageResource.create_image_api_image_resource(params)
    end

    # return an IIIF Collection resource (for multi-part works)
    # document = SolrDocument of series object
    # manifest_docs = Array of SolrDocument of volume-level objects
    def collection_for_manifests(document, manifest_docs)
      collection = IIIF::Presentation::Collection.new('@id' => document[:identifier_uri_ss].gsub(/\/[\w]+\z/, '/collection\\0'))
      collection.label = 'Multi-part work description'
      collection.viewing_hint = 'multi-part'
      collection.attribution = manifest_attribution(document).presence
      collection.metadata = manifest_metadata(document)
      collection.description = 'This document describes an IIIF Collection, which points to a series of IIIF Manifests comprising the individual items in this multi-volume work'
      if document[:license_ss]
        collection.license = cc_url(document[:license_ss]) if document[:license_ss].match?(/\(CC\s/)
      end
      collection.thumbnail = "#{document[:identifier_uri_ss]}/thumbnail" if document[:exemplary_image_ssi]
      manifest_docs.each do |manifest_doc|
        manifest_id = document[:identifier_uri_ss].gsub(/\/[\w]+\z/, manifest_doc.id.gsub(/\A[\w-]+:/, '/')) + '/manifest'
        collection.manifests << { '@id' => manifest_id,
                                  '@type' => 'sc:Manifest',
                                  'label' => render_title(manifest_doc, false) }
      end
      collection
    end

    # returns a basic Dublin Core-esque metadata set array
    # document = SolrDocument
    def manifest_metadata(document)
      manifest_metadata = []
      manifest_metadata << { label: t('blacklight.metadata_display.fields.title'), value: render_title(document) }
      manifest_metadata << { label: t('blacklight.metadata_display.fields.date'),
                             value: document[:date_tsim].first } if document[:date_tsim]

      if document[:name_tsim]
        names = setup_names_roles(document).first
        manifest_metadata << { label: t('blacklight.metadata_display.fields.creator'), value: names.length == 1 ? names.first : names }
      end

      if document[:publisher_tsi]
        pubplace = document[:pubplace_tsi] ? document[:pubplace_tsi] + ' : ' : ''
        manifest_metadata << { label: t('blacklight.metadata_display.fields.publisher'), value: pubplace + document[:publisher_tsi] }
      end

      some_fields = {
        type_of_resource_ssim: t('blacklight.metadata_display.fields.type_of_resource'),
        genre_basic_ssim: t('blacklight.metadata_display.fields.genre_basic'),
        abstract_tsi: t('blacklight.metadata_display.fields.abstract'),
        lang_term_ssim: t('blacklight.metadata_display.fields.language'),
        subject_facet_ssim: t('blacklight.metadata_display.fields.subject_topic'),
        physical_location_ssim: t('blacklight.metadata_display.fields.location'),
        related_item_host_ssim: t('blacklight.metadata_display.fields.collection')
      }
      some_fields.each do |k, v|
        values = document[k]
        manifest_metadata << { label: v, value: values.length == 1 ? values.first : values } if values
      end

      if document[:identifier_uri_ss]
        identifiers = [document[:identifier_uri_ss]]
        [:identifier_local_other_tsim, :identifier_local_call_tsim, :identifier_local_barcode_tsim, :identifier_isbn_tsim, :local_accession_id_tsim].each do |k|
          identifiers = identifiers + document[k] if document[k]
        end
        manifest_metadata << { label: t('blacklight.metadata_display.fields.id_local_other'), value: identifiers.length == 1 ? identifiers.first : identifiers }
      end

      if document[:rights_ss]
        rights = [document[:rights_ss]]
        rights << document[:license_ss]
        manifest_metadata << { label: t('blacklight.metadata_display.fields.rights'), value: rights.compact }
      end

      manifest_metadata
    end

    # returns the appropriate attribution statement
    def manifest_attribution(document)
      attribution_array = []
      [:rights_ss, :license_ss, :restrictions_on_access_ss].each do |field|
        attribution_array << document[field] if document[field]
      end
      attribution_array.blank? ? nil : attribution_array.join(' ')
    end

    # returns the appropriate label for the page/file
    # image_doc = ImageFile Solr document
    # index = the index of the page in the image_files array
    def label_for_canvas(image_doc, index)
      page_type = image_doc[:page_type_ssi]
      if page_type && page_type != 'Normal'
        case page_type
        when 'Title'
          'Title page'
        when 'Contents'
          'Table of Contents'
        else
          page_type
        end
      elsif image_doc[:page_num_label_ssi]
        "page #{image_doc[:page_num_label_ssi]}"
      else
        "image #{(index + 1)}"
      end
    end

    # set up the search service object
    # (@context and profile need to be at "0" for Universal Viewer to work)
    # document = SolrDocument
    def iiif_search_service(document)
      return unless Rails.application.routes.url_helpers.respond_to?(:solr_document_iiif_search_path)

      search_svc = IIIF::Service.new('@id' => "#{document[:identifier_uri_ss]}/iiif_search")
      search_svc['@context'] = 'http://iiif.io/api/search/0/context.json'
      search_svc['profile'] = 'http://iiif.io/api/search/0/search'
      search_svc['label'] = 'Search within this item'
      search_svc
    end
  end
end
