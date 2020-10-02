Rails.application.routes.draw do
  mount BlacklightAdvancedSearch::Engine => '/'

  # alias for map browse
  get 'places', to: 'catalog#map', as: 'places_facet'

  # formats browse
  get 'formats', to: 'catalog#formats_facet', as: 'formats_facet'

  # MODS metadata view
  get 'search/:id/metadata_view', to: 'catalog#metadata_view', as: 'metadata_view_catalog'

  # collections
  get 'collections/range_limit', to: 'collections#range_limit'
  # below seems to work, despite lack of #range_limit_panel action in CollectionsControllerBehavior
  get 'collections/range_limit_panel', to: 'collections#range_limit_panel'
  resources :collections, only: [:index, :show]
  get 'collections/facet/:id', to: 'collections#facet', as: 'collections_facet'

  # institutions
  get 'institutions/range_limit', to: 'institutions#range_limit'
  # below seems to work, despite lack of #range_limit_panel action in InstitutionsControllerBehavior
  get 'institutions/range_limit_panel', to: 'institutions#range_limit_panel'
  resources :institutions, only: [:index, :show]
  get 'institutions/facet/:id', to: 'institutions#facet', as: 'institutions_facet'

  # contact form
  # for some reason feedback submit won't work w/o this addition
  match 'feedback', to: 'feedback#show', via: [:get, :post]
  get 'feedback/complete', to: 'feedback#complete'

  # multi-image viewers
  get 'image_viewer/:id', to: 'image_viewer#show', as: 'image_viewer'
  get 'book_viewer/:id', to: 'image_viewer#book_viewer', as: 'book_viewer'

  # static pages
  get 'explore', to: 'pages#explore', as: 'explore'
  get 'about', to: 'pages#about', as: 'about'
  get 'about_this_site', to: 'pages#about_site', as: 'about_site'

  # IIIF manifest
  get 'search/:id/manifest', to: 'iiif_manifest#manifest', as: 'iiif_manifest'
  get 'search/:id/canvas/:canvas_object_id', to: 'iiif_manifest#canvas', as: 'iiif_canvas'
  get 'search/:id/annotation/:annotation_object_id', to: 'iiif_manifest#annotation', as: 'iiif_annotation'
  get 'search/:id/iiif_collection', to: 'iiif_manifest#collection', as: 'iiif_collection'
  post 'search/:id/manifest/cache_invalidate', to: 'iiif_manifest#cache_invalidate', as: 'iiif_cache_invalidate'

  # OCR search results
  get 'search/:id/fulltext', to: 'ocr_search#index', as: 'ocr_search'

  # downloads
  resources :downloads, only: [:show]
  get 'start_download/:id', to: 'downloads#trigger_download', as: 'trigger_downloads'
end
