module PlacesEngine
  module Extension
    module FeatureModel
      extend ActiveSupport::Concern

      included do
        has_many :altitudes, :dependent => :destroy
        has_many :category_features, :dependent => :destroy
        has_many :contestations, :dependent => :destroy
        has_many :cumulative_category_feature_associations, :dependent => :destroy
        has_many :feature_object_types, :order => :position, :dependent => :destroy
        has_many :shapes, :foreign_key => 'fid', :primary_key => 'fid'
        self.associated_models << FeatureObjectType
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
          first_township_relation = self.all_parent_relations.where(:perspective_id => geo_rel.id).first
          if !first_township_relation.nil?
            node = first_township_relation.parent_node
            break node.id if node.has_shapes?(options)
          end
          # check if county parent has shapes (county)
          pol_admin = Perspective.get_by_code('pol.admin.hier')
          first_county_relation = self.all_parent_relations.where(:perspective_id => pol_admin.id).first
          if !first_county_relation.nil?
            node = first_county_relation.parent_node
            break node.id if node.has_shapes?(options)
          end
          nil
        end
        feature_id.nil? ? nil : Feature.find(feature_id)
      end
      
      def descendants_by_topic(fids, topic_ids)
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
      
      def update_shape_positions
        shapes.reject{|shape| shape.position != 0}.inject(shapes.max{|a,b|a.position <=> b.position}.position+1) do |pos, shape|
          shape.update_attribute(:position, pos)
          pos + 1
        end
      end
      
      def kmaps_url
        "#{ActionController::Base.relative_url_root}/topics/#{self.fid}"
      end
      
      def topical_map_url
        "#{ActionController::Base.relative_url_root}/features/#{self.fid}/topics"
      end

      def kmap_path(type = nil)
        a = ['places', self.fid]
        a << type if !type.nil?
        a.join('/')
      end

      module ClassMethods
        def find_by_shape(shape)
          Feature.get_by_fid(shape.fid)
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
          self.descendants_by_perspective_with_parent(fids, perspective).select{|d| !CumulativeCategoryFeatureAssociation.where(:category_id => topic_ids, :feature_id => d[0].id).first.nil?}
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
          des.select{ |f_id| !CumulativeCategoryFeatureAssociation.where(:category_id => topic_ids, :feature_id => f_id).first.nil? }.collect{|f_id| Feature.find(f_id)}
        end
      end
    end
  end
end