module PlacesEngine
  module Extension
    module FeaturesController
      extend ActiveSupport::Concern

      included do
      end
      
      def search
        conditions = {:is_public => 1}
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
            @features = Feature.where(:is_public => 1, :fid => fid.gsub(/[^\d]/, '').to_i).page(1)
          else
            joins = []
            if !params[:object_type].blank?
              joins << "LEFT JOIN cumulative_category_feature_associations ccfa ON ccfa.feature_id = features.id"
              conditions['ccfa.category_id'] = params[:object_type].split(',')
              conditions['features.is_public'] = 1
              conditions.delete(:is_public)
            end
            if !params[:characteristic_id].blank?
              joins << "LEFT JOIN category_features cf ON cf.feature_id = features.id"
              conditions['cf.category_id'] = params[:characteristic_id].split(',')
              conditions['cf.type'] = nil
              conditions['features.is_public'] = 1
              conditions.delete(:is_public)
            end
            if !params[:has_descriptions].blank? && params[:has_descriptions] == '1'
              search_options[:has_descriptions] = true
            end
            @features = perform_global_search(search_options).where(conditions).paginate(:page => params[:page] || 1, :per_page => 10)
            @features = @features.joins(joins.join(' ')).select('features.*, DISTINCT feature.id') unless joins.empty?
          end
        #end
        # When using the session store features, we need to provide will_paginate with info about how to render
        # the pagination, so we'll store it in session[:search], along with the feature ids 
        session[:search] = { :params => @params.reject{|key, val| !valid_search_keys.include?(key.to_sym)},
          :page => @params[:page] ||= 1, :per_page => @features.per_page, :total_entries => @features.total_entries,
          :total_pages => @features.total_pages, :feature_ids => @features.collect(&:id) }
        # Set the current menu_item to 'results', so that the Results will stay open when the user browses
        # to a new page
        session[:interface] = {} if session[:interface].nil?
        session[:interface][:menu_item] = 'results'
        respond_to do |format|
          format.js # search.js.erb
          format.html { render :partial => 'search_results', :locals => {:features => @features} }
        end
      end
      
      def related_list
        @feature = Feature.find(params[:id])
        @feature_relation_type= FeatureRelationType.find(params[:feature_relation_type_id])
        @feature_is_parent = params[:feature_is_parent]
        @category = SubjectsIntegration::Feature.find(params[:category_id])
        @relations = CachedFeatureRelationCategory.where(
              'cached_feature_relation_categories.feature_id' => params[:id],
              'cached_feature_relation_categories.category_id' => params[:category_id],
              'cached_feature_relation_categories.feature_relation_type_id' => @feature_relation_type,
              'cached_feature_relation_categories.feature_is_parent' => @feature_is_parent,
              'cached_feature_names.view_id' => current_view.id
          ).joins('INNER JOIN "cached_feature_names" ON "cached_feature_relation_categories".related_feature_id = "cached_feature_names".feature_id INNER JOIN "feature_names" ON "cached_feature_names".feature_name_id = "feature_names".id'
          ).order('feature_names.name')
          # Should associations be set up to allow for this to be handled with :include instead?
        @total_relations_count = @relations.length
        @relations = @relations.paginate(:page => params[:page] || 1, :per_page => 8)
        @params = params
        # render related_list.js.erb
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
        geoserver_base = case InterfaceUtils::Server.environment
        when InterfaceUtils::Server::DEVELOPMENT then 'http://localhost:8080/thlib-geoserver/'
        when InterfaceUtils::Server::PRODUCTION  then 'http://localhost:8080/thdl-geoserver/'
        else                                          'http://www.thlib.org:8080/thdl-geoserver/'
        end
        if service.nil?
          render :nothing => true
        else
          url = geoserver_base+service+"?"+general_params+params
          begin
            send_data(open(url).read, :filename => name, :type => type, :disposition => 'attachment')
          rescue => e
            render :nothing => true
          rescue OpenURI::HTTPError => e
            render :nothing => true
          rescue Timeout::Error => e
            render :nothing => true
          end
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
      
      def topics
        @feature = Feature.get_by_fid(params[:id])
        if @feature.nil?
          redirect_to features_url
        else
          set_common_variables(session)
          session[:interface][:context_id] = @feature.id unless @feature.nil?
          @tab_options = {:entity => @feature}
          @current_tab_id = :topics
        end
      end
    end
  end
end
