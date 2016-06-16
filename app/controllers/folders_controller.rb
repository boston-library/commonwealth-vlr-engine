class FoldersController < CatalogController

  ##
  # Give Bookmarks access to the CatalogController configuration
  include Blacklight::Configurable
  include Blacklight::SearchHelper
  include Blacklight::TokenBasedUser

  copy_blacklight_config_from(CatalogController)

  # Blacklight uses #search_action_url to figure out the right URL for
  # the global search box
  def search_action_url options = {}
    search_catalog_url(options.except(:controller, :action))
  end
  helper_method :search_action_url

  before_filter :verify_user, :except => [:index, :show, :public_list]
  before_filter :check_visibility, :only => [:show]
  before_filter :correct_user_for_folder, :only => [:update, :destroy]

  def index
    flash[:notice] = flash[:notice].html_safe if flash[:notice].present? and flash[:notice] == %Q[Welcome! You're viewing Digital Stacks items using a link from a temporary card. To save these items to a free permanent account, click <a href="#{new_user_session_path}" title="Sign Up Link">Sign Up / Log In</a>.]
    if current_or_guest_user
      @folders = current_or_guest_user.folders
    end
  end

  def show
    flash[:notice] = flash[:notice].html_safe if flash[:notice].present? and flash[:notice] == %Q[Welcome! You're viewing Digital Stacks items using a link from a temporary card. To save these items to a free permanent account, click <a href="#{new_user_session_path}" title="Sign Up Link">Sign Up / Log In</a>.]

    # @folder is set by correct_user_for_folder
    @folder_items = @folder.folder_items
    folder_items_ids = @folder_items.collect { |f_item| f_item.document_id.to_s }
    params[:sort] ||= 'title_info_primary_ssort asc, date_start_dtsi asc'
    @response, @document_list = fetch(folder_items_ids)

    # have to declare this so view uses catalog/index partials
    # uh, maybe not? default templates won't get invoked if below is set
    #@partial_path_templates = ["catalog/%{action_name}_%{index_view_type}_%{format}"]
  end

  def new
    @folder = current_user.folders.new
  end

  def create
    @folder = current_user.folders.build(folder_params)
    if @folder.save
      flash[:notice] = "Folder created."
      redirect_to :action => "index"
    else
      render :action => "new"
    end
  end

  # create a folder in a modal window in the item show view
  #def create_folder_catalog
  #  if request.post?
  #    unless params[:title].empty?
  #      @folder = current_user.folders.build(:title => params[:title], :description => params[:description])
  #      if @folder.save
  #        flash[:success] = "Folder created; " + t('blacklight.folder_items.add.success')
  #        current_user.folders.first.folder_items.create!(:document_id => params['id'].first)
  #        redirect_to solr_document_path(params['id']) unless request.xhr?
  #      else
  #        flash[:error] = t('blacklight.folders.create.error.no_save')
  #      end
  #    else
  #      flash[:error] = t('blacklight.folders.create.error.no_title')
  #    end
  #  end

  #  unless !request.xhr? && flash[:success]
  #    respond_to do |format|
  #      format.js { render :layout => false }
  #      format.html { redirect_to :action => "new" }
  #    end
  #  end

  #end

  def edit
    @folder = Bpluser::Folder.find(params[:id])
  end

  def update
    # @folder is set by correct_user_for_folder
    if @folder.update_attributes(folder_params)
      flash[:notice] = "Folder updated."
      redirect_to @folder
    else
      render :action => "edit"
    end
  end

  def destroy
    # @folder is set by correct_user_for_folder
    @folder.destroy
    flash[:notice] = t('blacklight.folders.delete.success')
    redirect_to :action => "index"
  end

  # return a list of publicly visible folders that have items
  def public_list
    # TODO create a named scope for this query in Bplmodels::Folder?
    @folders = Bpluser::Folder.where(:visibility => 'public').joins(:folder_items).uniq.order('updated_at DESC')
  end

  private

    def folder_params
      params.require(:folder).permit(:id, :title, :description, :visibility)
    end

    def verify_user
      flash[:notice] = t('blacklight.folders.need_login') and raise Blacklight::Exceptions::AccessDenied unless current_user
    end

    def check_visibility
      @folder = Bpluser::Folder.find(params[:id])
      if @folder.visibility != 'public'
        correct_user_for_folder
      end
    end

    def correct_user_for_folder
      @folder ||= Bpluser::Folder.find(params[:id])
      if current_or_guest_user
        flash[:notice] = t('blacklight.folders.private') and redirect_to root_path unless current_or_guest_user.folders.include?(@folder)
      else
        flash[:notice] = t('blacklight.folders.private') and redirect_to root_path
      end
    end

end
