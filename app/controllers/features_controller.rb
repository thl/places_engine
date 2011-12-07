class FeaturesController < ApplicationController
  caches_page :show, :if => :api_response?.to_proc
  caches_action :node_tree_expanded, :cache_path => :tree_cache_path.to_proc #, :if => Proc.new { |c| c.request.xhr? }
  #
  def tree_cache_path
    set_common_variables(session) if params[:view_id] || params[:perspective_id]
    "tree/#{current_perspective.id}/#{current_view.id}/node_id_#{params[:id]}"
  end
  #
  #
  def index
    set_common_variables(session)
    
    @feature = Feature.find(session[:interface][:context_id]) unless session[:interface][:context_id].blank?
    @tab_options = {:entity => @feature}
    @current_tab_id = :home
    
    @active_menu_item = 'search'

    # In the event that a Blurb with this code doesn't exist, fail gracefully
    @intro_blurb = Blurb.find_by_code('homepage.intro') || Blurb.new
        
    respond_to do |format|
      format.html
      format.xml do
        render :action => 'index'
      end
    end
  end

  #
  #
  #
  def show
    @feature = Feature.get_by_fid(params[:id])
    if @feature.nil?
      redirect_to features_url
    else
      set_common_variables(session)
      session[:interface][:context_id] = @feature.id unless @feature.nil?
      @tab_options = {:entity => @feature}
      @current_tab_id = :place
      respond_to do |format|
        format.html
        format.xml
        format.csv
        format.json { render :json => Hash.from_xml(render_to_string(:action => 'show.xml.builder')), :callback => params[:callback] }
      end
    end
  end 

  #
  #
  #
  def iframe
    @feature = Feature.find(params[:id])
    render :action => 'iframe', :layout => 'iframe'
  end
  
  def by_geo_code
    set_common_variables(session)
    geo_code_type_str = params[:geo_code_type]
    geo_code_type = GeoCodeType.get_by_code(geo_code_type_str)
    @feature = nil
    if !geo_code_type.nil?
      geo_code = FeatureGeoCode.first(:conditions => {:geo_code_type_id => geo_code_type.id, :geo_code_value => params[:geo_code]})
      @feature = geo_code.feature if !geo_code.nil?
    end
    respond_to do |format|
      format.html { render :action => 'show' }
      format.xml  { render :action => 'show' }
      format.json { render :json => Hash.from_xml(render_to_string(:action => 'show.xml.builder')), :callback => params[:callback] }
    end
  end
    
  #
  #
  #
  def by_fid
    feature_array = params[:fids].split(/\D+/)
    feature_array.shift if feature_array.size>0 && feature_array.first.blank?
    @features =  feature_array.collect{|feature_id| Feature.get_by_fid(feature_id.to_i)}.find_all{|f| f && f.is_public==1}
    @view = params[:view_code].nil? ? nil : View.get_by_code(params[:view_code])
    respond_to do |format|
      format.html { render :action => 'staff_show' }
      format.xml  { render :action => 'index' }
      format.json { render :json => Hash.from_xml(render_to_string(:action => 'index.xml.builder')), :callback => params[:callback] }
    end
  end

  #
  #
  #
  def by_old_pid
    @features = params[:old_pids].split(/\D+/).find_all{|p| p && !p.blank?}.collect{|p| Feature.find_by_old_pid("f#{p}")}.find_all{|f| f}
    @view = params[:view_code].nil? ? nil : View.get_by_code(params[:view_code])
    respond_to do |format|
      format.html { render :action => 'staff_show' }
      format.xml  { render :action => 'index' }
      format.json { render :json => Hash.from_xml(render_to_string(:action => 'index.xml.builder')), :callback => params[:callback] }
    end
  end
  
  def by_name
    params[:filter] = params[:query]
    options={
      :page => params[:page] || 1,
      :per_page => params[:per_page] || 15,
      :conditions => {:is_public => 1}
    }
    search_options = {
      :scope => params[:scope] || 'name',
      :match => params[:match]
    }
    @view = params[:view_code].nil? ? nil : View.get_by_code(params[:view_code])
    joins = []
    if !params[:feature_type].blank?
      joins << "LEFT JOIN cumulative_category_feature_associations ccfa ON ccfa.feature_id = features.id"
      options[:conditions]['ccfa.category_id'] = params[:feature_type].split(',')
      options[:conditions]['features.is_public'] = 1
      options[:conditions].delete(:is_public)
    end
    if !params[:characteristic_id].blank?
      joins << "LEFT JOIN category_features cf ON cf.feature_id = features.id"
      options[:conditions]['cf.category_id'] = params[:characteristic_id].split(',')
      options[:conditions]['cf.type'] = nil
      options[:conditions]['features.is_public'] = 1
      options[:conditions].delete(:is_public)
    end  
    options[:joins] = joins.join(' ') unless joins.empty?
    options[:select] = "features.*, DISTINCT feature.id" unless joins.empty?
    perform_global_search(options, search_options)

    respond_to do |format|
      format.html { render :action => 'paginated_show' }
      format.xml  { render :action => 'paginated_show' }
      format.json { render :json => Hash.from_xml(render_to_string(:action => 'paginated_show.xml.builder')), :callback => params[:callback] }
    end
  end

  def fids_by_name
    params[:filter] = params[:query]
    options = { :conditions => { :is_public => 1 }, :include => :shapes }
    search_options = {
      :scope => params[:scope] || 'name',
      :match => params[:match]
    }
    joins = []
    if !params[:feature_type].blank?
      joins << 'LEFT JOIN cumulative_category_feature_associations ccfa ON ccfa.feature_id = features.id'
      options[:conditions]['ccfa.category_id'] = params[:feature_type].split(',')
      options[:conditions]['features.is_public'] = 1
      options[:conditions].delete(:is_public)
    end
    if !params[:characteristic_id].blank?
      joins << 'LEFT JOIN category_features cf ON cf.feature_id = features.id'
      options[:conditions]['cf.category_id'] = params[:characteristic_id].split(',')
      options[:conditions]['cf.type'] = nil
      options[:conditions]['features.is_public'] = 1
      options[:conditions].delete(:is_public)
    end
    options[:joins] = joins.join(' ') unless joins.empty?
    options[:select] = 'features.*, DISTINCT feature.id' unless joins.empty?
    perform_global_search(options, search_options)
    respond_to do |format|
      format.json { render :json => { :features => @features.reject{|f| f.shapes.empty?}.collect(&:fid) }, :callback => params[:callback] }
    end
  end
  
  def characteristics_list
    @kmaps_characteristics = CategoryFeature.find(:all, :select => "DISTINCT category_id", :conditions => "type IS NULL")
    render :json => @kmaps_characteristics.collect{|c| {:id => c.category_id, :name => c.to_s.strip}}.sort_by{|a| a[:name].downcase.strip}, :callback => params[:callback]
  end
  
  def gis_resources
    fids = params[:fids].split(/\D+/)
    fids.shift if fids.size>0 && fids.first.blank?
    features = fids.collect{|fid| Feature.get_by_fid(fid.to_i)}.find_all{|f| f && f.is_public==1}
    fids = features.collect{|f| f.pid.gsub(/[^\d]/, '')}
    if params[:contained] && params[:contained] == '1'
      contained_fids = features.collect{|feature| feature.descendants.collect{|f|f.pid.gsub(/[^\d]/, '')}}.flatten
      fids = fids | contained_fids
    end
    fids.collect!{|fid| "fid="+fid }
    render :text => "Sorry, this request includes too many features for us to currently be able to provide this data." and return if fids.length > 300
    cql_filter = fids.join("+OR+")
    
  	general_params = "version=1.0.0&typename=thl:roman_popular_poly,thl:roman_popular_pt&layers=thl:roman_popular_poly,thl:roman_popular_pt&styles=thl_noscale,thl_noscale&projection=EPSG%3A4326&srs=EPSG%3A4326&cql_filter=("+cql_filter+");("+cql_filter+")"
  	
    case params[:format]
    when 'gml'
      service = 'wfs'
      params = "&service=wfs&request=GetFeature&outputformat=GML2"
      type = 'text/xml'
      name = 'thl_gis.gml'
    when 'kml'
      service = 'wms'
      params = "&service=wms&request=GetMap&width=1600&height=750&bbox=-180.0,-90.0,180.0,90.0&format=application/vnd.google-earth.kml%20XML"
      type = 'text/xml'
      name = 'thl_gis.kml'
    when 'kmz'
      service = 'wms'
      params = "&service=wms&request=GetMap&width=1600&height=750&bbox=-180.0,-90.0,180.0,90.0&format=application/vnd.google-earth.kmz%20XML"
      type = 'application/vnd.google-earth.kmz'
      name = 'thl_gis.kmz'
    when 'shp'
      service = 'wfs'
      params = "&service=wfs&request=GetFeature&outputformat=shape-zip"
      type = 'application/zip'
      name = 'thl_gis.zip'
    end
    
    # Find the proper instance of GeoServer, based on the current environment
    hostname = Socket.gethostname.downcase
    if hostname == 'dev.thlib.org'
     geoserver_base = 'http://localhost:8080/thlib-geoserver/'
    elsif hostname =~ /sds[7-8].itc.virginia.edu/
     geoserver_base = 'http://localhost:8080/thdl-geoserver/'
    else
     geoserver_base = 'http://www.thlib.org:8080/thdl-geoserver/'
    end
    
    url = geoserver_base+service+"?"+general_params+params
    send_data(open(url).read, :filename => name, :type => type, :disposition => 'attachment')
  end
  
  def search
    options = { :page => params[:page] || 1, :per_page => 10, :conditions => {:is_public => 1} }
    search_options = { :scope => params[:scope], :match => params[:match] }
    @features = nil
    @params = params
    # The search params that should be observed when creating the session store of search params
    valid_search_keys = [:filter, :scope, :match, :search_scope, :object_type, :characteristic_id, :has_descriptions, :page ]
    fid = params[:fid]
    #search_scope = params[:search_scope].blank? ? 'global' : params[:search_scope]
    #if !search_scope.blank?
    #  case search_scope
    #  when 'fid'
    #    feature = Feature.find(:first, :conditions => {:is_public => 1, :fid => params[:filter].gsub(/[^\d]/, '').to_i})
    #    if !feature.id.nil?
    #      render :url => {:action => 'expand_and_show',  :id => '59' }, :layout => false
    #    else
    #    end
    #  when 'contextual'
    #    if !params[:object_type].blank?
    #      options[:joins] = "LEFT JOIN cumulative_category_feature_associations ccfa ON ccfa.feature_id = features.id"
    #      options[:conditions]['ccfa.category_id'] = params[:object_type].split(',')
    #      options[:conditions]['features.is_public'] = 1
    #      options[:conditions].delete(:is_public)
    #    end
    #    if params[:context_id].blank?
    #      perform_global_search(options, search_options)
    #    else
    #      perform_contextual_search(options, search_options)
    #    end
    #  when 'name'
    #    @features = Feature.name_search(params[:filter])
    #  else
      if !fid.blank?
        @features = Feature.paginate(:conditions => {:is_public => 1, :fid => fid.gsub(/[^\d]/, '').to_i}, :page => 1)
      else
        joins = []
        if !params[:object_type].blank?
          joins << "LEFT JOIN cumulative_category_feature_associations ccfa ON ccfa.feature_id = features.id"
          options[:conditions]['ccfa.category_id'] = params[:object_type].split(',')
          options[:conditions]['features.is_public'] = 1
          options[:conditions].delete(:is_public)
        end
        if !params[:characteristic_id].blank?
          joins << "LEFT JOIN category_features cf ON cf.feature_id = features.id"
          options[:conditions]['cf.category_id'] = params[:characteristic_id].split(',')
          options[:conditions]['cf.type'] = nil
          options[:conditions]['features.is_public'] = 1
          options[:conditions].delete(:is_public)
        end
        if !params[:has_descriptions].blank? && params[:has_descriptions] == '1'
          search_options[:has_descriptions] = true
        end
        options[:joins] = joins.join(' ') unless joins.empty?
        options[:select] = "features.*, DISTINCT feature.id" unless joins.empty?
        perform_global_search(options, search_options)
      end
    #end
    # When using the session store features, we need to provide will_paginate with info about how to render
    # the pagination, so we'll store it in session[:search], along with the feature ids 
    session[:search] = { :params => @params.reject{|key, val| !valid_search_keys.include?(key.to_sym)},
      :page => @params[:page] ||= 1, :per_page => @features.per_page, :total_entries => @features.total_entries,
      :total_pages => @features.total_pages, :feature_ids => @features.collect{|f|f.id} }
    # Set the current menu_item to 'results', so that the Results will stay open when the user browses
    # to a new page
    session[:interface] = {} if session[:interface].nil?
    session[:interface][:menu_item] = 'results'
    render :partial => 'search_results', :locals => {:features => @features}, :layout => false
  end
  
  def descendants
    @feature = Feature.find(params[:id])
    descendants = @feature.nil? ? [] : @feature.descendants(:include => {:cached_feature_names => :feature_name}, :order => {'cached_feature_names.view_id' => current_view.id}, :order => 'feature_names.name')
    descendants = descendants.paginate(:page => params[:page] || 1, :per_page => 10)
    render :partial => 'descendants', :locals => { :descendants => descendants }
  end
  
  def related
    set_common_variables(session)
    @feature = Feature.get_by_fid(params[:id])
    session[:interface][:context_id] = @feature.id unless @feature.nil?
    @tab_options = {:entity => @feature}
    @current_tab_id = :related
  end
  
  def related_list
    @feature = Feature.find(params[:id])
    @category = Category.find(params[:category_id])
    @relations = CachedFeatureRelationCategory.find(:all,
      :conditions => {
          'cached_feature_relation_categories.feature_id' => params[:id],
          'cached_feature_relation_categories.category_id' => params[:category_id],
          'cached_feature_relation_categories.feature_relation_type_id' => params[:feature_relation_type_id],
          'cached_feature_relation_categories.feature_is_parent' => params[:feature_is_parent],
          'cached_feature_names.view_id' => current_view.id
      },
      # Should associations be set up to allow for this to be handled with :include instead?
      :joins => 'INNER JOIN "cached_feature_names" ON "cached_feature_relation_categories".related_feature_id = "cached_feature_names".feature_id INNER JOIN "feature_names" ON "cached_feature_names".feature_name_id = "feature_names".id',
      :order => 'feature_names.name'
    )
    @total_relations_count = @relations.length
    @relations = @relations.paginate(:page => params[:page] || 1, :per_page => 8)
    @params = params
    render :partial => 'related_list'
  end
    
  # The following three methods are used with the Node Tree
  def expanded
    node = Feature.find(params[:id])
    render :partial => 'expanded', :locals => { :expanded => node }, :layout => false
  end

  def contracted
    node = Feature.find(params[:id])
    render :partial => 'contracted', :locals => { :contracted => node }, :layout => false
  end
  
  def node_tree_expanded
    set_common_variables(session) if params[:view_id] || params[:perspective_id]
    node = Feature.find(params[:id])
    @ancestors_for_current = node.current_ancestors(current_perspective, current_view).collect{|a| a.id}
    @ancestors_for_current << node.id
    top_level_nodes = Feature.current_roots(current_perspective, current_view)
    render :partial => 'node_tree', :locals => { :children => top_level_nodes }, :layout => false
  end  
    
  def set_session_variables
    defaults = {
      :menu_item => "search",
      :advanced_search => "0"
    }
    valid_keys = defaults.keys
    
    session[:interface] = {} if session[:interface].nil?
    params.each do |key, value|
      session[:interface][key.to_sym] = value if valid_keys.include?(key.to_sym)
    end
    render :text => ""
  end
  
  protected
  
    def search_scope_defined?
      !params[:search_scope].blank?
    end
    
    def contextual_search_selected?
      ('contextual' == params[:search_scope])
    end
    
    def global_search_selected?
      ('global' == params[:search_scope])
    end
    
    def fid_search_selected?
      ('fid' == params[:search_scope])
    end
    
    def perform_contextual_search(options, search_options={})
      @context_feature, @features = Feature.contextual_search(
        params[:context_id],
        params[:filter],
        options,
        search_options
        )
    end
    
    def perform_global_search(options, search_options={})
      @features = Feature.search(
        params[:filter],
        options,
        search_options
      )
    end
    
    def api_render(features, options={})
      collection = {}
      collection[:features] = features.collect{|f|
        api_format_feature(f)
      }
      collection[:page] = params[:page] || 1
      collection[:total_pages] = WillPaginate::ViewHelpers.total_pages_for_collection(features)
      respond_to do |format|
        format.xml { render :xml => collection.to_xml }
        format.json { render :json => collection.to_json, :callback => params[:callback] }
      end   
    end
    
    def api_format_feature(feature)
      f = {}
      f[:id] = feature.id
      f[:name] = feature.name
      f[:types] = feature.object_types.collect{|t| {:id => t.id, :title => t.title} }
      f[:descriptions] = feature.descriptions.collect{|d| {
        :id => d.id,
        :is_primary => d.is_primary,
        :title => d.title,
        :content => d.content,
      }}
      f[:has_shapes] = feature.shapes.empty? ? 0 : 1
      #f[:parents] = feature.parents.collect{|p| api_format_feature(p) }
      f
    end
    
    private
    
    def api_response?
      request.format.xml? # JSON because JSONP depends on parameters || request.format.json?
    end
end