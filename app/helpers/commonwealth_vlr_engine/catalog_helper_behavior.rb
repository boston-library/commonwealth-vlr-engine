# frozen_string_literal: true

module CommonwealthVlrEngine
  module CatalogHelperBehavior
    include CommonwealthVlrEngine::SearchHistoryConstraintsHelperBehavior
    include CommonwealthVlrEngine::RenderConstraintsHelperBehavior
    include CommonwealthVlrEngine::ImagesHelperBehavior
    include CommonwealthVlrEngine::LicenseHelperBehavior
    include CommonwealthVlrEngine::MetadataHelperBehavior
    include CommonwealthVlrEngine::FlaggedHelperBehavior

    def has_image_files?(files_hash)
      files_hash[:image].present?
    end

    def has_video_files?(files_hash)
      files_hash[:video].present?
    end

    def has_playable_audio?(files_hash)
      return false if files_hash[:audio].blank?

      files_hash[:audio].all? { |a| a['attachments_ss']['audio_access'].present? }
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

    # determine the 'truncate' length based on catalog#index view type
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

    def insert_opengraph_markup
      return unless controller_name == 'catalog' && action_name == 'show'

      content_for(:head) do
        render partial: '/catalog/opengraph', locals: { document: @document }
      end
    end

    # link to items starting with a specific letter
    def link_to_az_value(letter, field, search_path, link_class = nil)
      new_params = params.permit!.except(:controller, :action, :q, :page)
      new_params[:q] = "#{field}:#{letter}*"
      link_to(letter,
              self.send(search_path, new_params),
              class: link_class)
    end

    def render_item_breadcrumb(document, link_class = nil)
      setup_collection_links(document, link_class).sort.join(' / ').html_safe if document[:collection_ark_id_ssim]
    end

    # render the 'more like this' search link if doc has subjects
    def render_mlt_search_link(document)
      return unless document[:subject_facet_ssim] || document[:subject_geo_city_sim] || document[:related_item_host_ssim]

      content_tag :div, id: 'more_mlt_link_wrapper' do
        link_to t('blacklight.more_like_this.more_mlt_link'),
                search_catalog_path(mlt_id: document.id),
                id: 'more_mlt_link'
      end
    end

    # have to override to display non-typical constraints
    # (e.g. coordinates, mlt, range limit, advanced search)
    # need this until:
    # https://github.com/projectblacklight/blacklight_advanced_search/issues/53
    # https://github.com/projectblacklight/blacklight-maps/issues/84
    # https://github.com/projectblacklight/blacklight_range_limit/issues/49
    # are resolved
    def render_search_to_page_title(params)
      # this is ugly, but easiest way to deal with it; too many gems to try and solve it all here
      if params.respond_to?(:permit!)
        params_for_constraints = params.permit!.to_h
      else
        params_for_constraints = params
      end

      html_constraints = render_search_to_s(params_for_constraints).gsub(/<span class="filterValues">/, ' ')
      html_constraints = html_constraints.gsub(/<\/span>[\s]*<span class="constraint">/, ' / ')
      sanitize(html_constraints, tags: [])

      ## TODO: remove above and uncomment lines below after all issues have been resolved with
      ##       blacklight_advanced_search, blacklight_range_limit, and blacklight-maps
      # constraints = [render_search_to_page_title_mlt(params), super(params)]
      # constraints.reject { |item| item.blank? }.join(' / ')
    end

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
    def search_fields
      super.map { |f| [f[0].gsub(/\s\([\w\s]*\)/, ''), f[1]] }
    end
  end
end
