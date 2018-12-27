# use to share folder item actions (email, cite, delete) between folders and bookmarks
class FolderItemsActionsController < ApplicationController

  def folder_item_actions
    @folder = Bpluser::Folder.find(params[:id]) if params[:origin] == "folders"
    @user = current_or_guest_user
    if params[:selected]
      view_params = params.permit(:sort, :per_page, :view)
      items = params[:selected]

      case params[:commit]
        # email
        when t('blacklight.tools.email')
          redirect_to email_solr_document_path(:id => items)
        # cite
        when t('blacklight.tools.citation')
          redirect_to citation_solr_document_path(:id => items)
        # remove
        when t('blacklight.tools.remove')
          if params[:origin] == "folders"
            if @folder.folder_items.where(:document_id => items).delete_all
              flash[:notice] = I18n.t('blacklight.folders.update_items.remove.success')
            else
              flash[:error] = I18n.t('blacklight.folders.update_items.remove.failure')
            end
            redirect_to folder_path(@folder,
                                    view_params)
          else
            if current_or_guest_user.bookmarks.where(:document_id => items).delete_all
              flash[:notice] = I18n.t('blacklight.folders.update_items.remove.success')
            else
              flash[:error] = I18n.t('blacklight.folders.update_items.remove.failure')
            end
            redirect_to bookmarks_path(view_params)
          end
        # copy
        when /#{t('blacklight.tools.copy_to')}/
          destination = params[:commit].split(t('blacklight.tools.copy_to') + ' ')[1]
          if destination == t('blacklight.bookmarks.title')
            success = items.all? do |item_id|
              current_or_guest_user.bookmarks.create(:document_id => item_id) unless current_or_guest_user.bookmarks.where(:document_id => item_id).exists?
            end
          else
            folder_to_update = current_user.folders.find(destination)
            success = items.all? do |item_id|
              folder_to_update.folder_items.create!(:document_id => item_id) and folder_to_update.touch unless folder_to_update.has_folder_item(item_id)
            end
          end
          redirect_back(fallback_location: root_path)
          if success
            folder_display_name = destination == t('blacklight.bookmarks.title') ? t('blacklight.bookmarks.title') : folder_to_update.title
            flash[:notice] = t('blacklight.folders.update_items.copy.success',
                               :folder_name => folder_display_name)
          else
            flash[:error] = t('blacklight.folders.update_items.copy.failure')
          end
      end

    else
      redirect_back(fallback_location: root_path)
      flash[:error] = I18n.t('blacklight.folders.update_items.remove.no_items')
    end

  end

end
