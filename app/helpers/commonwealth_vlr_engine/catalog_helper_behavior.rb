# frozen_string_literal: true

module CommonwealthVlrEngine
  module CatalogHelperBehavior
    include CommonwealthVlrEngine::DocumentHelperBehavior
    include CommonwealthVlrEngine::ImagesHelperBehavior
    include CommonwealthVlrEngine::LicenseHelperBehavior
    include CommonwealthVlrEngine::MetadataHelperBehavior
    include CommonwealthVlrEngine::ShowToolsHelperBehavior

    def has_image_files?(files_hash)
      files_hash[:image].present?
    end

    def has_multiple_images?(files_hash)
      has_image_files?(files_hash) && files_hash[:image].size > 1
    end

    def has_video_files?(files_hash)
      files_hash[:video].present?
    end

    def has_audio_files?(files_hash)
      files_hash[:audio].present?
    end

    def has_document_files?(files_hash)
      files_hash[:document].present?
    end

    def has_pdf_files?(files_hash)
      (has_document_files?(files_hash) && files_hash[:document].any? { |a| has_attachment?(a, 'document_access') }) ||
        ((has_audio_files?(files_hash) || has_video_files?(files_hash)) &&
          %i(audio video).any? { |f| files_hash[f].any? { |a| has_attachment?(a, 'document_access') } })
    end

    def has_ereader_files?(files_hash)
      files_hash[:ereader].present?
    end

    # @param file_document [SolrDocument]
    # @param attachment_type [String]
    def has_attachment?(file_document, attachment_type)
      file_document['attachments_ss'][attachment_type].present?
    end

    def has_playable_audio?(files_hash)
      has_audio_files?(files_hash) && files_hash[:audio].all? { |a| has_attachment?(a, 'audio_access') }
    end

    # determine if the item has text content that can be searched
    def has_searchable_text?(document)
      return if document.blank?

      document['has_searchable_pages_bsi']
    end

    def include_uv?(document, files_hash)
      has_image_files?(files_hash) &&
        (has_searchable_text?(document) ||
          files_hash[:image].size > CommonwealthVlrEngine::Document::MediaComponent::IMAGE_VIEWER_LIMIT)
    end

    # need to render full title or too many pages have same <title>, bad for site SEO
    def show_html_title(options = {})
      render_title(options[:document])
    end

    def iiif_manifest_url(document)
      document[:identifier_iiif_manifest_ss]
    end

    def image_file_pids(images)
      images.map { |i| i[:id] }
    end

    # render collection name as a link in catalog#index list view
    def index_collection_link(options = {})
      setup_collection_links(options[:document]).join(' / ').html_safe
    end

    # render institution name as a link in catalog#index list view
    def index_institution_link(options = {})
      link_to(options[:value].first,
              institution_path(id: options[:document][:institution_ark_id_ssi]),
              class: 'index_institution_link')
    end

    def index_title(options = {})
      truncate(show_html_title(options), separator: ' ', length: index_title_length)
    end

    # determine the 'truncate' length based on catalog#index view type
    # note that this is NOT invoked when displaying item-level search results on
    # pages with a #show action (like institutions#show)
    def index_title_length
      case params[:view]
      when 'list'
        170
      when 'masonry'
        89
      else
        130
      end
    end

    def index_abstract(options = {})
      return '' if options[:value].blank?

      reformatted = options[:value].first.gsub(/<\/li><li>/, '; ').gsub(/(<br\/?>|<\/p><p>|<li>)/, ' ')
      truncate(HTMLEntities.new.decode(sanitize(reformatted, tags: [])).squish,
               length: options[:truncate_length] || 300,
               separator: ' ', omission: ' ... ') do
        link_to('more', public_send((options[:path_helper] || :collection_path), id: options[:document][:id]),
                aria: { label: t('blacklight.aria.label.abstract_more_link',
                                 genre: render_format_index({ value: options[:document]['genre_basic_ssim'] })&.split(', ').first.downcase || 'item') },
                class: 'read-more-link')
      end
    end

    # render abstract field, truncating w/'more' link if longer than 2 paragraphs
    # @param options [Hash] { value: document[:abstract_tsi], document: SolrDocument }
    def collapsed_abstract(options = {})
      desc_content = []
      # double quotes in #delete arg below are correct, DO NOT CHANGE
      abstract = options[:value].delete("\n").delete("\r").gsub(/<br[ \/]*>/, '<br/>').split('<br/><br/>')
      desc_content << content_tag(:div,
                                  abstract.first.html_safe,
                                  id: 'abstract_static',
                                  class: 'abstract_inline')
      if abstract.length > 1
        desc_content << content_tag(:div,
                                    abstract[1..(abstract.length - 1)].join('<br/><br/>').html_safe,
                                    id: 'abstract_collapse',
                                    class: 'collapse')
        desc_content << link_to(t('blacklight.metadata_display.expand'),
                                '#abstract_collapse',
                                data: { bs_toggle: 'collapse', toggle_text: t('blacklight.metadata_display.collapse') },
                                aria: {
                                  expanded: 'false', controls: 'abstract_collapse',
                                  label: t('blacklight.aria.label.abstract_more_link',
                                           genre: render_format_index({ value: options[:document]['genre_basic_ssim'] })&.split(', ').first.downcase || 'item')
                                },
                                id: 'abstract_expand', class: 'toggle_text')
      end
      desc_content.join('').html_safe
    end

    # @param document [SolrDocument]
    # @return [Boolean]
    def harvested_object?(document)
      document[blacklight_config.hosting_status_field.to_sym] == 'harvested'
    end

    # creates an array of collection links
    # for display on catalog#index list view and catalog#show breadcrumb
    def setup_collection_links(document, link_class = nil)
      coll_hash = {}
      0.upto(document[:collection_ark_id_ssim].length - 1) do |index|
        coll_hash[document[blacklight_config.collection_field.to_sym][index]] = document[:collection_ark_id_ssim][index]
      end
      coll_links = []
      coll_hash.sort.each do |coll_array|
        coll_links << link_to(coll_array[0],
                              collection_path(id: coll_array[1]),
                              class: link_class.presence)
      end
      coll_links
    end
  end
end
