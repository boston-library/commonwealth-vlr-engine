class FolderItemsController < CatalogController

  # give controller access to useful BL/Solr methods
  #include Blacklight::Configurable
  #include Blacklight::SearchHelper

  before_action :verify_user

  def update
    create
  end

  def create
    @response, @document = fetch(params[:id])
    if params[:folder_items]
      @folder_items = params[:folder_items]
    else
      @folder_items = [{ :document_id => params[:id], :folder_id => params[:folder_id] }]
    end

    success = @folder_items.all? do |f_item|
      folder_to_update = current_user.folders.find(f_item[:folder_id])
      folder_to_update.folder_items.create!(:document_id => f_item[:document_id]) and folder_to_update.touch unless folder_to_update.has_folder_item(f_item[:document_id])
    end

    unless request.xhr?
      flash[:notice] = t('blacklight.folder_items.add.success')
    end

    respond_to do |format|
      format.html { redirect_back(fallback_location: root_path) }
      format.js
    end

  end


  # Beware, :id is the Solr document_id, not the actual Bookmark id.
  # idempotent, as DELETE is supposed to be.
  # PRETTY SURE THIS METHOD IS NEVER USED!
  def destroy
    @response, @document = fetch(params[:id])
    folder_item = current_user.existing_folder_item_for(params[:id])

    # success = (!folder_item) || FolderItem.find(folder_item).destroy

    Bpluser::Folder.find(folder_item.folder_id).touch
    Bpluser::FolderItem.find(folder_item.id).destroy

    respond_to do |format|
      format.html { redirect_back(fallback_location: root_path) }
      format.js
    end

  end

  def clear
    @folder = Bpluser::Folder.find(params[:id])
    if current_user.folders.find(@folder.id).folder_items.clear
      @folder.touch
      flash[:notice] = I18n.t('blacklight.folder_items.clear.success')
    else
      flash[:error] = I18n.t('blacklight.folder_items.clear.failure')
    end
    redirect_to :controller => "folders", :action => "show", :id => @folder
  end

  # PRETTY SURE THIS METHOD IS NEVER USED!
  def delete_selected
    @folder = Bpluser::Folder.find(params[:id])
    if params[:selected]
      if @folder.folder_items.where(:document_id => params[:selected]).delete_all
        @folder.touch
        flash[:notice] = t('blacklight.folders.update_items.remove.success')
      else
        flash[:error] = t('blacklight.folders.update_items.remove.failure')
      end
      redirect_to :controller => "folders", :action => "show", :id => @folder
    else
      redirect_to :back
      flash[:error] = t('blacklight.folders.update_items.remove.no_items')
    end
  end

  protected
  def verify_user
    flash[:notice] = I18n.t('blacklight.folders.need_login') and raise Blacklight::Exceptions::AccessDenied unless current_user
  end

end
