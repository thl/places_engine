Rails.application.routes.draw do
  resources :categories do
    resources :counts, :controller => 'cached_category_counts'
  end
  resources :contestations
  namespace :admin do
    resources :altitudes do 
      resources :citations
      resources :notes do
        get :add_author, :on => :collection
      end
      resources :time_units do
        get :new_form, :on => :collection
      end
    end
    resources :category_features do
      resources :citations
      resources :notes do
        get :add_author, :on => :collection
      end
      resources :time_units do
        get :new_form, :on => :collection
      end
    end
    resources :features do
      resources :altitudes, :category_features, :feature_object_types, :shapes
      collection do
        match 'prioritize_feature_shapes/:id' => 'shapes#prioritize', :as => :prioritize_feature_shapes
        match 'prioritize_feature_types/:id' => 'feature_object_types#prioritize', :as => :prioritize_feature_object_types
      end
      
    end
    resources :feature_object_types do
      resources :citations
      resources :notes do
        get :add_author, :on => :collection
      end
      resources :time_units do
        get :new_form, :on => :collection
      end
    end
    resources :shapes do
      resources :notes do
        get :add_author, :on => :collection
      end
      resources :time_units do
        get :new_form, :on => :collection
      end
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
end