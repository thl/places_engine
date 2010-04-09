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
    admin.resources :alt_spelling_systems, :association_notes, :blurbs, :citations, :feature_name_types, :feature_relation_types, :feature_types,
                    :geo_code_types, :languages, :info_sources, :note_titles, :notes, :object_types, :orthographic_systems, :perspectives,
                    :phonetic_systems, :timespans, :users, :writing_systems, :xml_documents, :views
    admin.openid_new 'openid_new', :controller => 'users', :action => 'openid_new'
    admin.openid_create 'openid_create', :controller => 'users', :action => 'create', :requirements => { :method => :post }
    admin.admin '', :controller=>'features', :action=>'index'
    admin.resources :descriptions do |description|
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
    admin.resources :feature_name_relations, :has_many=>[:citations], :belongs_to=>[:feature_name] do |feature_name_relation|
      feature_name_relation.resources :notes, :collection => {:add_author => :get}
    end
    admin.resources :feature_names, :member=>{:locate_for_relation=>:get}, :has_many=>[:feature_name_relations, :citations], :belongs_to=>:feature do |feature_name|
      feature_name.resources :notes, :collection => {:add_author => :get}
      feature_name.resources :time_units, :collection => {:new_form => :get}
    end
    admin.resources :feature_relations, :has_many=>[:citations] do |feature_relation|
      feature_relation.resources :notes, :collection => {:add_author => :get}
      feature_relation.resources :time_units, :collection => {:new_form => :get}
    end
    admin.resources :features, :member=>{:locate_for_relation=>:get, :set_primary_description => :get}, :has_many => [ :feature_names, :feature_relations, :citations, :feature_object_types, :feature_geo_codes, :shapes] do |feature|
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
  map.resources :features, :has_many => :association_notes, :member => {:descendants => :get} do |feature|
    feature.resources :descriptions, :member => {:expand => :get, :contract => :get, :show => :get}
  end
  map.resources :feature_geo_codes, :has_many => :notes
  map.resources :feature_names, :has_many => :notes
  map.resources :feature_name_relations, :has_many => :notes
  map.resources :feature_object_types, :has_many => :notes
  map.resources :feature_relations, :has_many => :notes
  map.resources :shapes, :has_many => :notes
  map.resources :time_units, :has_many => :notes
  #map.resources :descriptions, :member => {:expand => :get, :contract => :get}
  map.with_options :path_prefix => 'features', :controller => 'features' do |features|
    features.by_fid 'by_fid/:fids.:format', :action => 'by_fid'
    features.by_old_pid 'by_old_pid/:old_pids', :action => 'by_old_pid'
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