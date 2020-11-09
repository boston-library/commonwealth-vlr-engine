# frozen_string_literal: true

# methods related to rendering images, thumbnails, icons, etc.
module CommonwealthVlrEngine
  module ImagesHelperBehavior
    # return the image url for the collection gallery view document
    # size = pixel length of square IIIF-created image
    def collection_gallery_url(document, size)
      exemplary_image_pid = document[:exemplary_image_ssi]
      if exemplary_image_pid
        if exemplary_image_pid.match(/oai/) ||
            document['exemplary_image_iiif_bsi'] == false
          datastream_disseminator_url(exemplary_image_pid, 'thumbnail300')
        else
          iiif_image_url(exemplary_image_pid, { region: 'square', size: "#{size}," })
        end
      else
        collection_icon_path
      end
    end

    def collection_icon_path
      asset_path('commonwealth-vlr-engine/dc_collection-icon.png')
    end

    def create_thumb_img_element(document, img_class = [])
      image_classes = img_class.class == Array ? img_class.join(' ') : ''
      image_tag(thumbnail_url(document),
                alt: document[blacklight_config.index.title_field.to_sym],
                class: image_classes)
    end

    # render the collection/institution icon if necessary
    def index_relation_base_icon document
      return unless document[blacklight_config.view_config(document_index_view_type).display_type_field]

      display_type = document[blacklight_config.view_config(document_index_view_type).display_type_field].downcase
      if controller_name == 'catalog' && (display_type == 'collection' || display_type == 'institution')
        image_tag("commonwealth-vlr-engine/dc_#{display_type}-icon.png", alt: "#{display_type} icon", class: "index-title-icon #{display_type}-icon")
      else
        ''
      end
    end

    # return the URL of an image to display in the catalog#index slideshow view
    def index_slideshow_img_url(document)
      if document[:exemplary_image_ssi] && !document[blacklight_config.flagged_field.to_sym]
        if document[blacklight_config.index.display_type_field.to_sym] == 'OAIObject' || document[:exemplary_image_ssi].match(/oai/)
          thumbnail_url(document)
        else
          iiif_image_url(document[:exemplary_image_ssi], { size: ',500' })
        end
      elsif document[:type_of_resource_ssim]
        render_object_icon_path(document[:type_of_resource_ssim].first)
      elsif document[blacklight_config.index.display_type_field.to_sym] == 'Collection'
        collection_icon_path
      elsif document[blacklight_config.index.display_type_field.to_sym] == 'Institution'
        institution_icon_path
      else
        render_object_icon_path(nil)
      end
    end

    def institution_icon_path
      asset_path('commonwealth-vlr-engine/dc_institution-icon.png')
    end

    # override Blacklight::CatalogHelperBehavior: don't want to pull thumbnail url from Solr
    def thumbnail_url(document)
      if document[:exemplary_image_ssi] && !document[blacklight_config.flagged_field.to_sym]
        datastream_disseminator_url(document[:exemplary_image_ssi], 'thumbnail300')
      elsif document[:type_of_resource_ssim]
        render_object_icon_path(document[:type_of_resource_ssim].first)
      elsif document[blacklight_config.index.display_type_field.to_sym] == 'Collection'
        collection_icon_path
      elsif document[blacklight_config.index.display_type_field.to_sym] == 'Institution'
        institution_icon_path
      else
        render_object_icon_path(nil)
      end
    end
  end
end
