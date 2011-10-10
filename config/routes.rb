ActionController::Routing::Routes.draw do |map|
  #map.resources :descriptions

  map.resources :contestations

  map.resources :languages

  map.authenticated_system_login  'login', :controller => 'sessions', :action => 'new'
  map.authenticated_system_logout 'logout', :controller => 'sessions', :action => 'destroy'
  
  map.resource :session
  map.resources(:categories, :member => {:expand => :get, :contract => :get}) do |category|
    category.resources(:children, :controller => 'categories', :member => {:expand => :get, :contract => :get})
    category.resources(:counts, :controller => 'cached_category_counts')
  end
  map.namespace(:admin) do |admin|
    admin.resources :alt_spelling_systems, :association_notes, :blurbs, :feature_name_types, :feature_relation_types, :feature_types,
                    :geo_code_types, :languages, :note_titles, :notes, :orthographic_systems, :perspectives,
                    :phonetic_systems, :users, :writing_systems, :xml_documents, :views
    admin.openid_new 'openid_new', :controller => 'users', :action => 'openid_new'
    admin.openid_create 'openid_create', :controller => 'users', :action => 'create', :requirements => { :method => :post }
    admin.admin '', :controller=>'features', :action=>'index'
    admin.resources :altitudes, :has_many=>[:citations], :belongs_to=>:feature do |altitude|
      altitude.resources :notes, :collection => {:add_author => :get}
      altitude.resources :time_units, :collection => {:new_form => :get}
    end    
    admin.resources :citations, :has_many => :pages
    admin.resources :descriptions, :has_many=>[:citations] do |description|
      description.resources :notes, :collection => {:add_author => :get}
      description.resources :time_units, :collection => {:new_form => :get}
    end
    admin.resources :feature_geo_codes, :has_many=>[:citations] do |feature_geo_code|
      feature_geo_code.resources :notes, :collection => {:add_author => :get}
      feature_geo_code.resources :time_units, :collection => {:new_form => :get}
    end
    admin.resources :feature_object_types, :has_many=>[:citations], :belongs_to=>:feature do |feature_object_type|
      feature_object_type.resources :notes, :collection => {:add_author => :get}
      feature_object_type.resources :time_units, :collection => {:new_form => :get}
    end
    admin.resources :category_features, :has_many=>[:citations], :belongs_to=>:feature do |feature_object_type|
      feature_object_type.resources :notes, :collection => {:add_author => :get}
      feature_object_type.resources :time_units, :collection => {:new_form => :get}
    end
    admin.resources :feature_name_relations, :has_many=>[:citations], :belongs_to=>[:feature_name] do |feature_name_relation|
      feature_name_relation.resources :notes, :collection => {:add_author => :get}
    end
    admin.resources :feature_names, :member=>{:locate_for_relation=>:get}, :has_many=>[:feature_name_relations, :citations], :belongs_to=>:feature do |feature_name|
      feature_name.resources :notes, :collection => {:add_author => :get}
      feature_name.resources :time_units, :collection => {:new_form => :get}
    end
    admin.resources :features_relation_types
    admin.resources :feature_relations, :has_many=>[:citations] do |feature_relation|
      feature_relation.resources :notes, :collection => {:add_author => :get}
      feature_relation.resources :time_units, :collection => {:new_form => :get}
    end
    admin.resources :features, :member=>{:locate_for_relation=>:get, :set_primary_description => :get, :clone => :post}, :has_many => [ :altitudes, :category_features, :citations, :feature_geo_codes, :feature_names, :feature_object_types, :feature_relations, :shapes] do |feature|
      feature.resources :association_notes, :collection => {:add_author => :get}
      feature.resources :descriptions, :collection => {:add_author => :get}
      feature.resources :time_units, :collection => {:new_form => :get}
    end
    admin.resources :feature_pids, :collection => {:available => :get}
    admin.resources :shapes do |shape|
      shape.resources :notes, :collection => {:add_author => :get}
      shape.resources :time_units, :collection => {:new_form => :get}
    end
    admin.resources :time_units do |time_unit|
      time_unit.resources :notes, :collection => {:add_author => :get}
    end
    admin.prioritize_feature_names 'prioritize_feature_names/:id', :path_prefix => 'admin/features', :controller => 'feature_names', :action => 'prioritize'
    admin.prioritize_feature_object_types 'prioritize_feature_types/:id', :path_prefix => 'admin/features', :controller => 'feature_object_types', :action => 'prioritize'
    admin.prioritize_feature_shapes 'prioritize_feature_shapes/:id', :path_prefix => 'admin/features', :controller => 'shapes', :action => 'prioritize'
  end # end admin urls
  map.resources :features, :has_many => :association_notes, :member => {:descendants => :get, :related => :get} do |feature|
    feature.resources :descriptions, :member => {:expand => :get, :contract => :get, :show => :get}
    feature.by_topic 'by_topic/:id.:format', :controller => 'topics', :action => 'feature_descendants'
  end
  map.resources :altitudes, :has_many => [:notes, :citations]
  map.resources :category_features, :has_many => [:notes, :citations]
  map.resources :description, :has_many => [:notes, :citations]
  map.resources :feature_geo_codes, :has_many => [:notes, :citations]
  map.resources :feature_names, :has_many => [:notes, :citations]
  map.resources :feature_name_relations, :has_many => [:notes, :citations]
  map.resources :feature_object_types, :has_many => [:notes, :citations]
  map.resources :feature_relations, :has_many => [:notes, :citations]
  map.resources :media, :as => 'media_objects', :only => 'show'
  map.resources :shapes, :has_many => [:notes, :citations]
  map.resources :time_units, :has_many => [:notes, :citations]
  map.resources :topics, :only => 'show'
  #map.resources :descriptions, :member => {:expand => :get, :contract => :get}
  map.with_options :path_prefix => 'features', :controller => 'features' do |features|
    features.by_fid 'by_fid/:fids.:format', :action => 'by_fid'
    features.by_old_pid 'by_old_pid/:old_pids', :action => 'by_old_pid'
    features.by_geo_code 'by_geo_code/:geo_code.:format', :action => 'by_geo_code'
    # Allow an empty :query for feature type searches
    features.by_name 'by_name/:query.:format', :action => 'by_name', :query => /.*?/
    features.gis_resources 'gis_resources/:fids.:format', :action => 'gis_resources'
  end  
  map.root :controller=>'features', :action=>'index'
  
  map.connect ':controller/:action/:id.:format'
  map.connect ':controller/:action/:id'
  
  # The priority is based upon order of creation: first created -> highest priority.
  
  # Sample of regular route:
  # map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action
  
  # Sample of named route:
  # map.purchase 'products/:id/purchase', :controller => 'catalog', :action => 'purchase'
  # This route can be invoked with purchase_url(:id => product.id)
  
  # You can have the root of your site routed by hooking up '' 
  # -- just remember to delete public/index.html.
  # map.connect '', :controller => "welcome"
  
  # Allow downloading Web Service WSDL as a file with an extension
  # instead of a file named 'wsdl'
  #map.connect ':controller/service.wsdl', :action => 'wsdl'
  
  # Install the default route as the lowest priority.
  #map.connect ':controller/:action/:id.:format'
  #map.connect ':controller/:action/:id'
end
