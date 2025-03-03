Rails.application.routes.draw do

  root to: 'pages#home'

  # TODO: this bookmarks stuff should be in bpluser generator?
  # bookmarks item actions
  # this has to be in local app for bookmark item actions to work
  put 'bookmarks/item_actions', to: 'folder_items_actions#folder_item_actions', as: 'selected_bookmarks_actions'


  concern :iiif_search, BlacklightIiifSearch::Routes.new
  concern :range_searchable, BlacklightRangeLimit::Routes::RangeSearchable.new
  mount Blacklight::Engine => '/'
  # root to: "catalog#index"
  concern :searchable, Blacklight::Routes::Searchable.new

  resource :catalog, only: [], as: 'catalog', path: '/search', controller: 'catalog' do
    concerns :searchable
    concerns :range_searchable

  end

  concern :exportable, Blacklight::Routes::Exportable.new

  resources :solr_documents, only: [:show], path: '/search', controller: 'catalog' do
    concerns :exportable
    concerns :iiif_search
  end

  resources :bookmarks, only: [:index, :update, :create, :destroy] do
    concerns :exportable

    collection do
      delete 'clear'
    end
  end
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/*
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest

  # Defines the root path route ("/")
  # root "posts#index"
end