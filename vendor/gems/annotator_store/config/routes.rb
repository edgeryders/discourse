require_dependency "annotator_constraint"


Rails.application.routes.draw do

  namespace :annotator, constraints: AnnotatorConstraint.new  do

    root to: 'application#front'
    resources :topics, only: [:index, :show]
    resources :videos, only: [:show]

    namespace :annotator_store, path: '' do
      resources :tags, path: 'codes'
      resources :tag_names
      resources :collections
      resources :languages
      resources :user_settings
      # Search
      match 'search', to: 'pages#search', via: [:get], defaults: {format: :json}, constraints: {format: :json}
      match 'search', to: 'annotations#options', via: [:options], defaults: {format: :json}, constraints: {format: :json}
      # Annotations Endpoint
      resources :annotations, only: [:index, :show], defaults: {format: :html}, constraints: {format: :html}

      resources :annotations, only: [:index, :create, :show, :edit, :update, :destroy], defaults: {format: :json}, constraints: {format: :json} do
        match '/', to: 'annotations#options', via: [:options], on: :collection
        match '/', to: 'annotations#options', via: [:options], on: :member
      end
      resources :text_annotations, only: [:index, :show, :edit, :update]
      resources :video_annotations, only: [:index, :show, :edit, :update]
      resources :image_annotations, only: [:index, :show, :edit, :update]
    end
  end

end
