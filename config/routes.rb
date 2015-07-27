Rails.application.routes.draw do

  mount Bpluser::Engine => '/bpluser'

  # alias for map browse
  get 'places', :to => 'catalog#map', :as => 'places_facet'

  # formats browse
  get 'formats', :to => 'catalog#formats_facet', :as => 'formats_facet'

  # MODS metadata view
  get 'search/:id/metadata_view', :to => 'catalog#metadata_view', :as => 'metadata_view_catalog'

  # collections
  resources :collections, :only => [:index, :show]
  get 'collections/facet/:id', :to => 'collections#facet', :as => 'collections_facet'

  # institutions
  resources :institutions, :only => [:index, :show]
  get 'institutions/facet/:id', :to => 'institutions#facet', :as => 'institutions_facet'

  # contact form
  # for some reason feedback submit won't work w/o this addition
  match 'feedback', :to => 'feedback#show', :via => [:get, :post]
  get 'feedback/complete', :to => 'feedback#complete'

  # folders
  get 'folders/public', :to => 'folders#public_list', :as => 'public_folders'
  resources :folders
  delete 'folder/:id/clear', :to => 'folder_items#clear', :as => 'clear_folder_items'
  put 'folder/:id/item_actions', :to => 'folder_items_actions#folder_item_actions', :as => 'selected_folder_items_actions'

  # folder items
  resources :folder_items

  # user account management (not login/auth)
  resources :users, :only => [:show, :index]

  # multi-image viewers
  get 'image_viewer/:id', :to => 'image_viewer#show', :as => 'image_viewer'
  get 'book_viewer/:id', :to => 'image_viewer#book_viewer', :as => 'book_viewer'

  # static pages
  get 'explore', :to => 'pages#explore', :as => 'explore'
  get 'about', :to => 'pages#about', :as => 'about'
  get 'about_this_site', :to => 'pages#about_site', :as => 'about_site'

  # IIIF manifest
  get 'iiif_manifest/:id', :to => 'iiif_manifest#manifest', :as => 'iiif_manifest'

  # DEPRECATED ROUTES AND EXAMPLES

  # this is generated into local app via CommonwealthVlrEngine::RoutesGenerator
  #devise_for :users, :controllers => {:omniauth_callbacks => "users/omniauth_callbacks", :registrations => "users/registrations", :sessions => "users/sessions"}

  # this is added to Blacklight::Routes via CommonwealthVlrEngine::Routes
  #put 'bookmarks/item_actions', :to => 'folder_items_actions#folder_item_actions', :as => 'selected_bookmarks_actions'

  # custom 'search' path routes are added to Blacklight::Routes::RouteSets via CommonwealthVlrEngine::RouteSets
  # copy the below into local app to add all BL routes manually (remove blacklight_for call)
  #delete 'bookmarks/clear', :to => 'bookmarks#clear', :as => 'clear_bookmarks'
  #resources :bookmarks
  #get 'search_history', :to => 'search_history#index', :as => 'search_history'
  #delete 'search_history/clear', :to => 'search_history#clear', :as => 'clear_search_history'
  #delete 'saved_searches/clear', :to => 'saved_searches#clear', :as => 'clear_saved_searches'
  #get 'saved_searches', :to => 'saved_searches#index', :as => 'saved_searches'
  #put 'saved_searches/save/:id', :to => 'saved_searches#save', :as => 'save_search'
  #delete 'saved_searches/forget/:id', :to => 'saved_searches#forget', :as => 'forget_search'
  #post 'saved_searches/forget/:id', :to => 'saved_searches#forget'
  #get 'search/opensearch', :to => 'catalog#opensearch', :as => 'opensearch_catalog'
  #get 'search/citation', :to => 'catalog#citation', :as => 'citation_catalog'
  #get 'search/email', :as => 'email_catalog'
  #post 'search/email'
  #match 'search/email', :to => 'catalog#email', :as => 'email_catalog', :via => [:get, :post]
  #get 'search/facet/:id', :to => 'catalog#facet', :as => 'catalog_facet'
  #get 'search', :to => 'catalog#index', :as => 'catalog_index'
  #resources :solr_document, :path => 'search', :controller => 'catalog', :only => [:show, :update] do
  #  member do
  #    post 'track'
  #  end
  #end
  # :show and :update are for backwards-compatibility with catalog_url named routes
  #resources :catalog, :only => [:show, :update]
  # end local BL routes override

end