Rails.application.routes.draw do

  mount Bpluser::Engine => '/bpluser'

  #devise_for :users, :controllers => {:omniauth_callbacks => "users/omniauth_callbacks", :registrations => "users/registrations", :sessions => "users/sessions"}

  # not using the default BL pattern below as it requires controller and path to have same name
  # blacklight_for :catalog

  # this needs to be before BL bookmarks stuff
  put 'bookmarks/item_actions', :to => 'folder_items_actions#folder_item_actions', :as => 'selected_bookmarks_actions'

  # add all BL routes manually -- stopgap solution until patch can be submitted
  # that will allow local app to provide :path option for resources passed as
  # args to blacklight/lib/blacklight/rails/routes.rb#blacklight_for
  delete 'bookmarks/clear', :to => 'bookmarks#clear', :as => 'clear_bookmarks'
  resources :bookmarks
  get 'search_history', :to => 'search_history#index', :as => 'search_history'
  delete 'search_history/clear', :to => 'search_history#clear', :as => 'clear_search_history'
  delete 'saved_searches/clear', :to => 'saved_searches#clear', :as => 'clear_saved_searches'
  get 'saved_searches', :to => 'saved_searches#index', :as => 'saved_searches'
  put 'saved_searches/save/:id', :to => 'saved_searches#save', :as => 'save_search'
  delete 'saved_searches/forget/:id', :to => 'saved_searches#forget', :as => 'forget_search'
  post 'saved_searches/forget/:id', :to => 'saved_searches#forget'
  get 'search/opensearch', :to => 'catalog#opensearch', :as => 'opensearch_catalog'
  get 'search/citation', :to => 'catalog#citation', :as => 'citation_catalog'
  #get 'search/email', :as => 'email_catalog'
  #post 'search/email'
  match 'search/email', :to => 'catalog#email', :as => 'email_catalog', :via => [:get, :post]
  get 'search/facet/:id', :to => 'catalog#facet', :as => 'catalog_facet'
  get 'search', :to => 'catalog#index', :as => 'catalog_index'
  resources :solr_document, :path => 'search', :controller => 'catalog', :only => [:show, :update] do
    member do
      post 'track'
    end
  end
  # :show and :update are for backwards-compatibility with catalog_url named routes
  resources :catalog, :only => [:show, :update]
  # end local BL routes override

  get 'places', :to => 'catalog#map', :as => 'places_facet'
  get 'formats', :to => 'catalog#formats_facet', :as => 'formats_facet'

  get 'search/:id/metadata_view', :to => 'catalog#metadata_view', :as => 'metadata_view_catalog'

  #HydraHead.add_routes(self) # deprecated in HH7

  resources :downloads, :only => [:show]

  resources :collections, :only => [:index, :show]
  get 'collections/facet/:id', :to => 'collections#facet', :as => 'collections_facet'

  resources :institutions, :only => [:index, :show]
  get 'institutions/facet/:id', :to => 'institutions#facet', :as => 'institutions_facet'

  # for some reason feedback submit won't work w/o this addition
  match 'feedback', :to => 'feedback#show', :via => [:get, :post]
  get 'feedback/complete', :to => 'feedback#complete'

  get 'folders/public', :to => 'folders#public_list', :as => 'public_folders'

  resources :folders

  resources :folder_items

  get 'preview/:id', :to => 'preview#preview', :as => 'preview'
  get 'full_image/:id', :to => 'preview#full', :as => 'full_image'
  get 'large_image/:id', :to => 'preview#large', :as => 'large_image'

  delete 'folder/:id/clear', :to => 'folder_items#clear', :as => 'clear_folder_items'
  #match "folder/:id/remove", :to => "folder_items#delete_selected", :as => "delete_selected_folder_items"
  put 'folder/:id/item_actions', :to => 'folder_items_actions#folder_item_actions', :as => 'selected_folder_items_actions'


  resources :users, :only => [:show, :index]

  get 'image_viewer/:id', :to => 'image_viewer#show', :as => 'image_viewer'
  get 'book_viewer/:id', :to => 'image_viewer#book_viewer', :as => 'book_viewer'

  get 'explore', :to => 'pages#explore', :as => 'explore'
  get 'about', :to => 'pages#about', :as => 'about'
  get 'about_this_site', :to => 'pages#about_site', :as => 'about_site'

#CommonwealthVlrEngine::Engine.routes.draw do

end

