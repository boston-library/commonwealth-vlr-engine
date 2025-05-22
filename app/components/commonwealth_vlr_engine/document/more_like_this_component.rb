# frozen_string_literal: true

module CommonwealthVlrEngine
  module Document
    class MoreLikeThisComponent < ViewComponent::Base
      def initialize(document:, mlt_response:)
        @document = document
        @mlt_response = mlt_response
      end
      attr_reader :document, :mlt_response

      # need to pass view_config, or presenter will use blacklight_config.show.metadata_component
      def mlt_documents_presenters
        mlt_response.documents.map do |doc| CommonwealthVlrEngine::IndexPresenter.new(
          doc, controller.view_context, view_config: helpers.blacklight_config.view_config(:index)
        )
        end
      end

      # render the 'more like this' search link if doc has subjects
      def mlt_search_link
        return unless document[:subject_facet_ssim] || document[:subject_geo_city_sim] || document[:related_item_host_ssim]

        content_tag :div, id: 'more_mlt_link_wrapper' do
          link_to I18n.t('blacklight.more_like_this.more_mlt_link'),
                  helpers.search_catalog_path(mlt_id: document[:id]),
                  id: 'more_mlt_link'
        end
      end

      def render?
        mlt_response&.documents.present?
      end
    end
  end
end
