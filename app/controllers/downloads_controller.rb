# frozen_string_literal: true

class DownloadsController < ApplicationController
  include CommonwealthVlrEngine::DownloadsControllerBehavior
  # ActionController::Live has to be included here, since it doesn't play well with Zipline,
  # and therefore can't be included in shared DownloadsControllerBehavior module
  include ActionController::Live

  # render a page/modal with license terms, download links, etc
  def show
    @doc_response, @document = search_service.fetch(params[:id])
    if @document[:curator_model_ssi].include? 'Filestream'
      _parent_response, @parent_document = search_service.fetch(parent_id(@document))
      @object_profile = JSON.parse(@document['attachments_ss'])
    else
      @parent_document = @document
      @object_profile = nil
    end

    respond_to do |format|
      format.html do
        render layout: false if request.xhr?
      end # for users w/o JS
      format.js { render layout: false } # download modal window
    end
  end

  # initiates the file download
  def trigger_download
    not_found unless verify_recaptcha

    @solr_document = SolrDocument.find(params[:id])
    if params[:filestream_id].present? && @solr_document[:curator_model_ssi].include?('Filestream')
      @object_id = parent_id(@solr_document)
      @attachments = JSON.parse(@solr_document[:attachments_ss])
      send_content
    else
      not_found
    end
  end
end
