AnnotatorStore::Engine.routes.draw do

  # Root path
  root 'pages#index', defaults: { format: :json }

  get 'topic/:id', to: 'topics#show', as: 'annotator_store_topic'
  get 'video/:id', to: 'videos#show', as: 'annotator_store_video'

  # Search
  match 'search', to: 'pages#search', via: [:get], defaults: { format: :json }, constraints: { format: :json }
  match 'search', to: 'annotations#options', via: [:options], defaults: { format: :json }, constraints: { format: :json }

  # Annotations Endpoint
  resources :annotations, only: [:create, :show, :update, :destroy], defaults: { format: :json }, constraints: { format: :json } do
    match '/', to: 'annotations#options', via: [:options], on: :collection
    match '/', to: 'annotations#options', via: [:options], on: :member
  end


end
