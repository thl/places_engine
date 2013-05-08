Rails.application.routes.draw do
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
    resources :features do
      resources :altitudes, :shapes
      collection do
        match 'prioritize_feature_shapes/:id' => 'shapes#prioritize', :as => :prioritize_feature_shapes
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
  resources :shapes do
    resources :notes, :citations
  end
end