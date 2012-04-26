Rails.application.routes.draw do
  resources :contestations, :languages
  resource :session
  resources :categories do
    member do
      get :expand
      get :contract
    end
    resources :children do
      member do
        get :expand
        get :contract
      end
    end
    resources :counts
  end
  namespace :admin do
    resources :alt_spelling_systems, :association_notes, :blurbs, :feature_name_types, :feature_relation_types,
      :feature_types, :geo_code_types, :languages, :note_titles, :notes, :orthographic_systems, :perspectives,
      :phonetic_systems, :users, :writing_systems, :xml_documents, :views
    match 'openid_new' => 'users#openid_new'
    match 'openid_create' => 'users#create', :via => :post
    root :to => 'features#index'
    resources :citations do
      resources :pages
    end
    resources :descriptions do
      resources :citations
      resources :notes do
        get :add_author, :on => :collection
      end
      resources :time_units do
        get :new_form, :on => :collection
      end
    end
    resources :feature_geo_codes do
      resources :citations
      resources :notes do
        get :add_author, :on => :collection
      end
      resources :time_units do
        get :new_form, :on => :collection
      end
    end
    resources :feature_relations do
      resources :citations
      resources :notes do
        get :add_author, :on => :collection
      end
      resources :time_units do
        get :new_form, :on => :collection
      end
    end
    resources :features do
      member do
        get :set_primary_description
        get :locate_for_relation
        post :clone
      end
      resources :citations, :feature_geo_codes, :feature_relations
      resources :altitudes do
        resources :citations
        resources :notes do
          get :add_author, :on => :collection
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
        resources :time_units do
          get :new_form, :on => :collection
        end
      end
      resources :association_notes do
        get :add_author, :on => :collection
      end
      resources :descriptions do
        get :add_author, :on => :collection
      end
      resources :feature_names do
        resources :citations
        get :locate_for_relation, :on => :member
        resources :notes do
          get :add_author, :on => :collection
        end
        resources :feature_name_relations do
          resources :citations
          resources :notes do
            get :add_author, :on => :collection
          end
        end
        resources :time_units do
          get :new_form, :on => :collection
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
      resources :time_units do
        get :new_form, :on => :collection
      end
    end
    resources :feature_pids do
      get :available, :on => :collection
    end
    resources :people do
      resource :user
    end
    resources :shapes do
      resources :notes do
        get :add_author, :on => :collection
      end
      resources :time_units do
        get :new_form, :on => :collection
      end
    end
    resources :time_units do
      resources :notes do
        get :add_author, :on => :collection
      end
    end
    match 'prioritize_feature_names/:id' => 'feature_names#prioritize', :as => :prioritize_feature_names, :path_prefix => 'admin/features'
    match 'prioritize_feature_types/:id' => 'feature_object_types#prioritize', :as => :prioritize_feature_object_types, :path_prefix => 'admin/features'
    match 'prioritize_feature_shapes/:id' => 'shapes#prioritize', :as => :prioritize_feature_shapes, :path_prefix => 'admin/features'
  end
  resources :features do
    get :search, :on => :collection
    resources :association_notes
    member do
      get :descendants
      get :related
    end
    resources :descriptions do
      member do
        get :expand
        get :show
        get :contract
      end
    end
    match 'by_topic/:id.:format' => 'topics#feature_descendants', :as => :by_topic
  end
  resources :altitudes do
    resources :notes, :citations
  end
  resources :category_features do
    resources :notes, :citations
  end
  resources :description do
    resources :notes, :citations
  end
  resources :feature_geo_codes do
    resources :notes, :citations
  end
  resources :feature_names do
    resources :notes, :citations
  end
  resources :feature_name_relations do
    resources :notes, :citations
  end
  resources :feature_object_types do
    resources :notes, :citations
  end
  resources :feature_relations do
    resources :notes, :citations
  end
  resources :media, :only => "show", :path => 'media_objects'
  resources :shapes do
    resources :notes, :citations
  end
  resources :time_units do
    resources :notes, :citations
  end
  resources :topics, :only => "show"
  match 'by_fid/:fids.:format' => 'features#by_fid', :as => :by_fid, :path_prefix => 'features'
  match 'by_old_pid/:old_pids' => 'features#by_old_pid', :as => :by_old_pid, :path_prefix => 'features'
  match 'by_geo_code/:geo_code.:format' => 'features#by_geo_code', :as => :by_geo_code, :path_prefix => 'features'
  match 'by_name/:query.:format' => 'features#by_name', :as => :by_name, :query => /.*?/, :path_prefix => 'features'
  match 'fids_by_name/:query.:format' => 'features#fids_by_name', :as => :fids_by_name, :query => /.*?/, :path_prefix => 'features'
  match 'gis_resources/:fids.:format' => 'features#gis_resources', :as => :gis_resources, :path_prefix => 'features'
  root :to => 'features#index'
  
  match ':controller(/:action(/:id(.:format)))'
end