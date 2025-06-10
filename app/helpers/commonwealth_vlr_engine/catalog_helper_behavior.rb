# frozen_string_literal: true

module CommonwealthVlrEngine
  module CatalogHelperBehavior
    # include CommonwealthVlrEngine::SearchHistoryConstraintsHelperBehavior
    # include CommonwealthVlrEngine::RenderConstraintsHelperBehavior
    include CommonwealthVlrEngine::DocumentHelperBehavior
    include CommonwealthVlrEngine::ImagesHelperBehavior
    include CommonwealthVlrEngine::LicenseHelperBehavior
    include CommonwealthVlrEngine::MetadataHelperBehavior
    # include CommonwealthVlrEngine::FlaggedHelperBehavior
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

    def has_ereader_files?(files_hash)
      files_hash[:ereader].present?
    end

    def has_playable_audio?(files_hash)
      has_audio_files?(files_hash) && files_hash[:audio].all? { |a| a['attachments_ss']['audio_access'].present? }
    end
    #
    # def has_pdf_files?(files_hash)
    #   has_document_files?(files_hash) && files_hash[:document].any? { |a| a['attachments_ss']['document_access'].present? }
    # end
    #
    # def book_reader?(document, files_hash)
    #   has_image_files?(files_hash) && (has_searchable_text?(document) || files_hash[:image].size > IMAGE_VIEWER_LIMIT)
    # end

    # need to render full title or too many pages have same <title>, bad for site SEO
    def show_html_title(options = {})
      render_title(options[:document])
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
              institution_path(id: options[:document][:institution_ark_id_ssi]))
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
      truncate(sanitize(options[:value].first.gsub(/<\/p><p>/, ' '), :tags => []),
               length: options[:truncate_length] || 300,
               separator: ' ', omission: '... ') do
        link_to('more', public_send((options[:path_helper] || :collection_path), id: options[:document][:id]),
                class: 'read-more-link')
      end
    end

    def insert_opengraph_markup
      return unless action_name == 'show' && %w(catalog collections).include?(controller_name)

      content_for(:head) do
        render partial: '/catalog/opengraph', locals: { document: @document }
      end
    end

    # @deprecated - moved to AzLinksComponent
    # link to items starting with a specific letter
    # def link_to_az_value(letter, field, search_path, link_class = nil)
    #   new_params = params.permit!.except(:controller, :action, :q, :page)
    #   new_params[:q] = "#{field}:#{letter}*"
    #   link_to(letter, self.send(search_path, new_params), class: link_class)
    # end

    # @param document [SolrDocument]
    # @return [Boolean]
    def harvested_object?(document)
      document[blacklight_config.hosting_status_field.to_sym] == 'harvested'
    end

    # @param document_files [Array] Curator::Filestreams::Document SolrDocument objects
    # @return [Boolean]
    # def pdf_url_for_viewer(document_files)
    #   pdf_file = document_files.find { |a| a['attachments_ss']['document_access'].present? }
    #   filestream_disseminator_url(pdf_file['storage_key_base_ss'], 'document_access')
    # end

    # @param document [SolrDocument]
    # @param files_hash [Hash] output of CommonwealthVlrEngine::Finder.get_files
    # @return [Boolean]
    def render_image_viewer?(document, files_hash)
      has_image_files?(files_hash) && files_hash[:image].length <= IMAGE_VIEWER_LIMIT && !has_searchable_text?(document)
    end

    def render_image_viewer(document, files_hash)
      case files_hash[:image].count
      when 1
        render partial: 'catalog/_show_partials/show_default_img',
               locals: { document: document,
                         image_key: files_hash[:image].first['storage_key_base_ss'],
                         page_sequence: { total: 1 } }
      when 2..IMAGE_VIEWER_LIMIT
        render partial: 'catalog/_show_partials/show_multi_img',
               locals: { document: document, image_files: files_hash[:image] }
      end
    end

    # DEPRECATED, moved to CommonwealthVlrEngine::BreadcrumbComponent
    # def render_item_breadcrumb(document, link_class = nil)
    #   setup_collection_links(document, link_class).sort.join(' / ').html_safe if document[:collection_ark_id_ssim]
    # end

    # @param files_hash [Hash] output of CommonwealthVlrEngine::Finder.get_files
    # @return [Boolean]
    # def render_pdf_viewer?(files_hash)
    #   has_pdf_files?(files_hash) && !has_multiple_images?(files_hash) && !has_playable_audio?(files_hash)
    # end

    # @param document [SolrDocument]
    # @param files_hash [Hash] output of CommonwealthVlrEngine::Finder.get_files
    # @return [Boolean]
    def render_thumbnail_wrapper?(document, files_hash)
      book_reader?(document, files_hash) || harvested_object?(document)
    end

    # have to override to display non-typical constraints
    # (e.g. coordinates, mlt, range limit, advanced search)
    # need this until:
    # https://github.com/projectblacklight/blacklight_advanced_search/issues/53
    # https://github.com/projectblacklight/blacklight-maps/issues/84
    # https://github.com/projectblacklight/blacklight_range_limit/issues/49
    # are resolved
    # def render_search_to_page_title(params)
    #   # this is ugly, but easiest way to deal with it; too many gems to try and solve it all here
    #   if params.respond_to?(:permit!)
    #     params_for_constraints = params.permit!.to_h
    #   else
    #     params_for_constraints = params
    #   end
    #
    #   html_constraints = render_search_to_s(params_for_constraints).gsub(/<span class="filterValues">/, ' ')
    #   html_constraints = html_constraints.gsub(/<\/span>[\s]*<span class="constraint">/, ' / ')
    #   sanitize(html_constraints, tags: [])
    #
    #   ## TODO: remove above and uncomment lines below after all issues have been resolved with
    #   ##       blacklight_advanced_search, blacklight_range_limit, and blacklight-maps
    #   # constraints = [render_search_to_page_title_mlt(params), super(params)]
    #   # constraints.reject { |item| item.blank? }.join(' / ')
    # end

    # TODO: uncomment and write spec after issues identified with render_search_to_page_title resolved
    # def render_search_to_page_title_mlt(params)
    #   return "".html_safe if params[:mlt_id].blank?
    #   "#{t('blacklight.search.filters.label', :label => t('blacklight.more_like_this.constraint_label'))} #{h
    #  (params[:mlt_id])}"
    # end

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

    # override from Blacklight::ConfigurationHelperBehavior
    # remove extraneous text from search field labels
    # but leave them as-is on Advanced Search
    # def search_fields
    #   return super if controller_name == 'advanced'
    #
    #   super.map { |f| [f[0].gsub(/\s\([\w\s]*\)/, ''), f[1]] }
    # end
  end
end
