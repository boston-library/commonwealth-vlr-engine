# frozen_string_literal: true

# methods related to rendering images, thumbnails, icons, etc.
module CommonwealthVlrEngine
  module ImagesHelperBehavior
    NEWSPAPER_GALLERY_REGION = 'pct:4,3,90,67'

    # return the image url for the collection gallery view document
    # @param document [SolrDocument] = Curator::Collection Solr document
    # @param size [String] = pixel length of square IIIF-created image
    # @return [String]
    def collection_gallery_url(document, size)
      exemplary_image_pid = document[:exemplary_image_ssi]
      if exemplary_image_pid
        if harvested_object?(document) || document['exemplary_image_iiif_bsi'] == false
          filestream_disseminator_url(document[:exemplary_image_key_base_ss], 'image_thumbnail_300')
        elsif document[:destination_site_ssim].to_s.include?('newspapers')
          iiif_image_url(exemplary_image_pid, { region: NEWSPAPER_GALLERY_REGION, size: "#{size},#{size}" })
        else
          iiif_image_url(exemplary_image_pid, { region: 'square', size: "#{size}," })
        end
      else
        collection_icon_url
      end
    end

    def banner_image_url(exemplary_document:)
      if exemplary_document
        if exemplary_document[blacklight_config.hosting_status_field] != 'hosted' || exemplary_document[:identifier_iiif_manifest_ss].blank?
          filestream_disseminator_url(exemplary_document[:exemplary_image_key_base_ss], 'image_thumbnail_300')
        else
          banner_image_iiif_url(image_ark_id: exemplary_document[:exemplary_image_ssi],
                                destination_site: exemplary_document[:destination_site_ssim])
        end
      else
        icon_url(exemplary_document[blacklight_config.index.display_type_field].downcase)
      end
    end

    def banner_image_iiif_url(image_ark_id:, destination_site: %w(commonwealth), target_width: 1100, target_height: 450)
      image_info = get_image_metadata(image_ark_id)
      output_aspect = target_width.to_f / target_height.to_f
      if image_info[:aspect_ratio] > output_aspect
        top = 0
        height = image_info[:height]
        width = (height * output_aspect).round
      else
        width = (image_info[:width].to_f * 0.90).round # 90% so we don't get borders
        reduction_percent = (target_width.to_f / width.to_f).round(3)
        height = (target_height / reduction_percent).round
        # use the top section if this is a newspaper page, otherwise use the middle
        top = destination_site.include?('newspapers') ? 200 : (image_info[:height] - height) / 2
      end
      left = (image_info[:width] - width) / 2
      region = "#{left},#{top},#{width},#{height}"
      size_width = image_info[:width] < target_width ? image_info[:width] : target_width
      iiif_image_url(image_ark_id, { region: region, size: "#{size_width}," })
    end

    def collection_icon_url
      asset_url('commonwealth-vlr-engine/dc_collection-icon.png')
    end

    def create_thumb_img_element(document, img_class = [])
      image_classes = img_class.class == Array ? img_class.join(' ') : ''
      image_tag(thumbnail_url(document),
                alt: document[blacklight_config.index.title_field.field],
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

    # DEPRECATED, we no longer support slideshow view
    # return the URL of an image to display in the catalog#index slideshow view
    # def index_slideshow_img_url(document)
    #   if document[:exemplary_image_ssi] && document[blacklight_config.flagged_field.to_sym] != 'explicit'
    #     if document[blacklight_config.index.display_type_field.to_sym] == 'OAIObject' || document[:exemplary_image_ssi].match(/oai/)
    #       thumbnail_url(document)
    #     else
    #       iiif_image_url(document[:exemplary_image_ssi], { size: ',500' })
    #     end
    #   elsif document[:type_of_resource_ssim]
    #     render_object_icon_path(document[:type_of_resource_ssim].first)
    #   elsif document[blacklight_config.index.display_type_field.to_sym] == 'Collection'
    #     collection_icon_url
    #   elsif document[blacklight_config.index.display_type_field.to_sym] == 'Institution'
    #     institution_icon_path
    #   else
    #     render_object_icon_path(nil)
    #   end
    # end

    def institution_icon_path
      asset_path('commonwealth-vlr-engine/dc_institution-icon.png')
    end

    # TODO: this should probably be set in ThumbnailPresenter
    def thumbnail_url(document)
      thumbnail_att_name = 'image_thumbnail_300'
      if document[:exemplary_image_ssi] && document[blacklight_config.flagged_field.to_sym] != 'explicit'
        if document[blacklight_config.index.display_type_field.to_sym] == 'Institution'
          attachment_json = JSON.parse(document[:attachments_ss])
          filestream_disseminator_url(attachment_json[thumbnail_att_name]['key'], thumbnail_att_name, true)
        else
          filestream_disseminator_url(document[:exemplary_image_key_base_ss], thumbnail_att_name)
        end
      elsif document[:type_of_resource_ssim]
        render_object_icon_path(document[:type_of_resource_ssim].first)
      elsif document[blacklight_config.index.display_type_field.to_sym] == 'Collection'
        collection_icon_url
      elsif document[blacklight_config.index.display_type_field.to_sym] == 'Institution'
        institution_icon_path
      else
        render_object_icon_path(nil)
      end
    end
  end
end
