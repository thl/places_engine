module PlacesEngine
  module Extension
    module FeatureModel
      extend ActiveSupport::Concern
      include Rails.application.routes.url_helpers
      
      included do
        has_many :altitudes, :dependent => :destroy
        has_many :category_features, :dependent => :destroy
        has_many :contestations, :dependent => :destroy
        has_many :cumulative_category_feature_associations, :dependent => :destroy
        has_many :feature_object_types, -> { order :position }, :dependent => :destroy
        has_many :shapes, :foreign_key => 'fid', :primary_key => 'fid'
        has_many :cached_feature_relation_categories, :dependent => :destroy
        self.associated_models << FeatureObjectType
      end
      
      def pid
        "F#{self.fid}"
      end

      def has_shapes?(options = {})
        use_log_in_status = options.has_key? :logged_in?
        shapes = self.shapes
        return use_log_in_status ? (options[:logged_in?] ? !shapes.empty? : shapes.any?(&:is_public?)) : !shapes.empty?
      end

      # Options take :logged_in?
      def closest_feature_with_shapes(options = {})
        feature_id = Rails.cache.fetch("features/#{self.fid}/closest_feature_with_shapes", :expires_in => 1.hour) do
          break self.id if self.has_shapes?(options)
          # check if geographical parent has shapes (township)
          geo_rel = Perspective.get_by_code('geo.rel')
          first_township_relation = self.all_parent_relations.find_by(perspective_id: geo_rel.id)
          if !first_township_relation.nil?
            node = first_township_relation.parent_node
            break node.id if node.has_shapes?(options)
          end
          # check if county parent has shapes (county)
          pol_admin = Perspective.get_by_code('pol.admin.hier')
          first_county_relation = self.all_parent_relations.find_by(perspective_id: pol_admin.id)
          if !first_county_relation.nil?
            node = first_county_relation.parent_node
            break node.id if node.has_shapes?(options)
          end
          nil
        end
        feature_id.nil? ? nil : Feature.find(feature_id)
      end
      
      def descendants_by_topic(topic_ids)
        self.descendants_by_topic([self.fid], topic_ids)
      end
      
      def descendants_by_topic_with_parent(topic_ids)
        Feature.descendants_by_topic_with_parent([self.fid], topic_ids)
      end
      
      #
      # Shortcut for getting all feature_object_types.object_types
      #
      def object_types
        feature_object_types.collect(&:category).select{|c| c}
      end
      
      def update_object_type_positions
        feature_object_types.where(:position => 0).order('created_at').inject(feature_object_types.maximum(:position)+1) do |pos, fot|
          fot.update_attribute(:position, pos)
          pos + 1
        end
      end
      
      def update_cached_feature_relation_categories
        CachedFeatureRelationCategory.destroy_all(:feature_id => self.id)
        CachedFeatureRelationCategory.destroy_all(:related_feature_id => self.id)

      	self.all_relations.each do |relation|
      		relation.child_node.feature_object_types.each do |fot|
      		  CachedFeatureRelationCategory.create({
      		    :feature_id => relation.parent_node_id,
      		    :related_feature_id => relation.child_node_id,
      		    :category_id => fot.category_id,
      		    :feature_relation_type_id => relation.feature_relation_type_id,
      		    :feature_is_parent => true,
      		    :perspective_id => relation.perspective_id
      		  })
      		end
      		parent_node = relation.parent_node
      		if !parent_node.nil?
      		  parent_node.feature_object_types.each do |fot|
        		  CachedFeatureRelationCategory.create({
        		    :feature_id => relation.child_node_id,
        		    :related_feature_id => relation.parent_node_id,
        		    :category_id => fot.category_id,
        		    :feature_relation_type_id => relation.feature_relation_type_id,
        		    :feature_is_parent => false,
        		    :perspective_id => relation.perspective_id
        		  })
        		end
    		  end
      	end
      end

      def category_count
        CategoryFeature.where(:feature_id => self.id).count
      end
      
      def media_count(options = {})
        media_count_hash = Rails.cache.fetch("#{self.cache_key}/media_count", :expires_in => 1.day) do
          media_place_count = MmsIntegration::MediaPlaceCount.find(:all, :params => {:place_id => self.fid}).to_a
          media_count_hash = { 'Medium' => media_place_count.shift.count.to_i }
          media_place_count.each{|count| media_count_hash[count.medium_type] = count.count.to_i }
          media_count_hash
        end
        type = options[:type]
        return type.nil? ? media_count_hash['Medium'] : media_count_hash[type]
      end
      
      def update_shape_positions
        shapes.reject{|shape| shape.position != 0}.inject(shapes.max{|a,b|a.position <=> b.position}.position+1) do |pos, shape|
          shape.update_attribute(:position, pos)
          pos + 1
        end
      end
      
      def kmap_path(type = nil)
        a = ['places', self.fid]
        a << type if !type.nil?
        a.join('/')
      end
      
      def context_feature
        ancestors = self.current_ancestors(Perspective.get_by_code('pol.admin.hier'))
        parent = ancestors.detect{|a| a.fid != self.fid && a.feature_object_types.detect{|ft| ft.category_id==29}}
        parent = self.parents.first if parent.nil?
        return parent
      end

      def solr_id
        "places-#{self.fid}"
      end
      
      def document_for_rsolr
        doc = RSolr::Xml::Document.new
        doc.add_field('tree', 'places')
        self.object_types.each do |o|
          doc.add_field('feature_types', o.header)
          doc.add_field('feature_type_ids', o.id)
        end
        perspectives = ['cult.reg', 'pol.admin.hier'].collect{ |code| Perspective.get_by_code(code) }
        perspectives.each do |p|
          hierarchy = self.closest_ancestors_by_perspective(p)
          tag = "ancestors_#{p.code}"
          hierarchy.each{ |f| doc.add_field(tag, f.prioritized_name(View.get_by_code('roman.popular'))) }
          tag = "ancestor_ids_#{p.code}"
          hierarchy.each{ |f| doc.add_field(tag, f.fid) }
        end
        closest = self.closest_feature_with_shapes
        closest_fid = closest.nil? ? nil : closest.fid
        url = closest_fid.nil? ? nil : "#{InterfaceUtils::Server.get_thl_url}/places/maps/interactive/#fid:#{closest_fid}"
        doc.add_field('interactive_map_url', url) if !url.nil?
        url = closest_fid.nil? ? nil : gis_resources_url(:fids => closest_fid, :host => InterfaceUtils::Server.get_url, :format => 'kmz')
        doc.add_field('has_shapes', self.has_shapes?)
        doc.add_field('has_altitudes', self.altitudes.count>0)
        closest = self.closest_feature_with_shapes
        closest_fid = closest.nil? ? nil : closest.fid
        doc.add_field('closest_fid_with_shapes', closest_fid) if !closest_fid.nil?
        doc
      end

      module ClassMethods
        def find_by_shape(shape)
          Feature.find_by(fid: shape.fid)
        end
        
        def descendants_by_topic_with_parent(fids, topic_ids)
          pending = fids.collect{|fid| Feature.get_by_fid(fid)}
          des = pending.collect{|f| [f, nil]}
          des_ids = pending.collect(&:id)
          while !pending.empty?
            e = pending.pop
            FeatureRelation.where(:parent_node_id => e.id).each do |r|
              c = r.child_node
              if !des_ids.include? c.id
                des_ids << c.id
                des << [c, e, r]
                pending.push(c)
              end
            end
          end
          topic_ids = topic_ids.first if topic_ids.size==1
          des.select{ |d| !CumulativeCategoryFeatureAssociation.where(:category_id => topic_ids, :feature_id => d[0].id).first.nil? }
        end
        
        def descendants_by_perspective_and_topics_with_parent(fids, perspective, topic_ids)
          topic_ids = topic_ids.first if topic_ids.size==1
          self.descendants_by_perspective_with_parent(fids, perspective).select{|d| !CumulativeCategoryFeatureAssociation.find_by(category_id: topic_ids, feature_id: d[0].id).nil?}
        end
        
        def descendants_by_topic(fids, topic_ids)
          pending = fids.collect{|fid| Feature.get_by_fid(fid)}
          des = []
          while !pending.empty?
            e = pending.pop
            FeatureRelation.select('child_node_id').where(:parent_node_id => e, :feature_relation_type_id => FeatureRelationType.hierarchy_ids + [FeatureRelationType.get_by_code('is.contained.by').id]).each do |r|
              c = r.child_node_id
              if !des.include? c
                des << c
                pending.push(c)
              end
            end
          end
          topic_ids = topic_ids.first if topic_ids.size==1
          des.select{ |f_id| !CumulativeCategoryFeatureAssociation.find_by(category_id: topic_ids, feature_id: f_id).nil? }.collect{|f_id| Feature.find(f_id)}
        end
      end
    end
  end
end