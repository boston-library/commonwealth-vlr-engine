# -*- encoding : utf-8 -*-
class BookmarksController < CatalogController

  include Blacklight::Bookmarks

  # LOCAL OVERRIDE to render update.js.erb partial when bookmark created
  def create
    if params[:bookmarks]
      @bookmarks = params[:bookmarks]
    else
      @bookmarks = [{ document_id: params[:id], document_type: blacklight_config.document_model.to_s }]
    end

    current_or_guest_user.save! unless current_or_guest_user.persisted?

    success = @bookmarks.all? do |bookmark|
      current_or_guest_user.bookmarks.where(bookmark).exists? || current_or_guest_user.bookmarks.create(bookmark)
    end

    if request.xhr?
      # success ? render(json: { bookmarks: { count: current_or_guest_user.bookmarks.count }}) : render(:text => "", :status => "500")
      success ? render(:update) : render(:text => "", :status => "500")
    else
      if @bookmarks.length > 0 && success
        flash[:notice] = I18n.t('blacklight.bookmarks.add.success', :count => @bookmarks.length)
      elsif @bookmarks.length > 0
        flash[:error] = I18n.t('blacklight.bookmarks.add.failure', :count => @bookmarks.length)
      end

      redirect_to :back
    end
  end

  def folder_item_actions
    redirect_to :action => "index"
  end

end