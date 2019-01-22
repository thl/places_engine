Rails.application.routes.draw do
  
  resources :categories do
    resources :counts, controller: 'cached_category_counts'
  end
  resources :contestations
  namespace :admin do
    resources :altitudes do
      resources :citations
      resources :notes do
        get :add_author, on: :collection
      end
      resources :time_units do
        get :new_form, on: :collection
      end
    end
    resources :category_features do
      resources :citations
      resources :notes do
        get :add_author, on: :collection
      end
      resources :time_units do
        get :new_form, on: :collection
      end
    end
    resources :features do
      resources :altitudes, :category_features, :feature_object_types, :shapes
      collection do
        get 'prioritize_feature_shapes/:id', to: 'shapes#prioritize', as: :prioritize_feature_shapes
        get 'prioritize_feature_types/:id', to: 'feature_object_types#prioritize', as: :prioritize_feature_object_types
      end
    end
    resources :feature_object_types do
      resources :citations
      resources :notes do
        get :add_author, on: :collection
      end
      resources :time_units do
        get :new_form, on: :collection
      end
      post :set_priorities, on: :collection
    end
    resources :shapes do
      resources :citations
      resources :notes do
        get :add_author, on: :collection
      end
      resources :time_units do
        get :new_form, on: :collection
      end
      post :set_priorities, on: :collection
    end
  end
  resources :altitudes do
    resources :notes, :citations
  end
  resources :category_features do
    resources :notes, :citations
  end
  resources :feature_object_types do
    resources :notes, :citations
  end
  resources :shapes do
    resources :notes, :citations
  end
  scope 'features' do
    get ':id/topics', to: 'features#topics', as: :topics_feature
    get ':feature_id/locations', to: 'locations#index', as: :feature_locations
    get 'gis_resources/:fids.:format', to: 'features#gis_resources', as: :gis_resources
    get ':feature_id/by_topic/:id.:format', to: 'topics#feature_descendants'
  end
  resources :topics, only: 'show'
end
