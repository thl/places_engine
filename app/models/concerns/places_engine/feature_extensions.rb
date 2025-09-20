module PlacesEngine
  module FeatureExtensions
    extend ActiveSupport::Concern
    
    included do
      has_many :altitudes, dependent: :destroy
      has_many :category_features, dependent: :destroy
      has_many :contestations, dependent: :destroy
      has_many :cumulative_category_feature_associations, dependent: :destroy
      has_many :feature_object_types, -> { order :position }, dependent: :destroy
      has_many :shapes, foreign_key: 'fid', primary_key: 'fid'
      has_many :cached_feature_relation_categories, dependent: :destroy
      self.associated_models << FeatureObjectType
      #include Rails.application.routes.url_helpers
    end
    
    def pid
      "F#{self.fid}"
    end

    def has_shapes?(**options)
      use_log_in_status = options.has_key? :logged_in?
      shapes = self.shapes
      return use_log_in_status ? (options[:logged_in?] ? !shapes.empty? : shapes.any?(&:is_public?)) : !shapes.empty?
    end

    # Options take :logged_in?
    def closest_feature_with_shapes(**options)
      feature_id = Rails.cache.fetch("features/#{self.fid}/closest_feature_with_shapes", expires_in: 1.hour) do
        break self.id if self.has_shapes?(**options)
        # check if geographical parent has shapes (township)
        geo_rel = Perspective.get_by_code('geo.rel')
        first_township_relation = self.all_parent_relations.find_by(perspective_id: geo_rel.id)
        if !first_township_relation.nil?
          node = first_township_relation.parent_node
          break node.id if node.has_shapes?(**options)
        end
        # check if county parent has shapes (county)
        pol_admin = Perspective.get_by_code(KmapsEngine::ApplicationSettings.default_perspective_code)
        first_county_relation = self.all_parent_relations.find_by(perspective_id: pol_admin.id)
        if !first_county_relation.nil?
          node = first_county_relation.parent_node
          break node.id if node.has_shapes?(**options)
        end
        nil
      end
      feature_id.nil? ? nil : Feature.find(feature_id)
    end
    
    def descendants_by_topic(topic_ids)
      Feature.descendants_by_topic([self.fid], topic_ids)
    end
    
    def descendants_by_topic_with_parent(topic_ids)
      Feature.descendants_by_topic_with_parent([self.fid], topic_ids)
    end
    
    def faceted_descendants(**options)
      Feature.faceted_descendants(**options.merge(fids: [self.fid]))
    end
    
    #
    # Shortcut for getting all feature_object_types.object_types
    #
    def object_types
      feature_object_types.collect(&:category).select{|c| c}
    end
    
    def update_object_type_positions
      feature_object_types.where(position: 0).order('created_at').inject(feature_object_types.maximum(:position)+1) do |pos, fot|
        fot.update_attribute(:position, pos)
        pos + 1
      end
    end
    
    def update_cached_feature_relation_categories
      CachedFeatureRelationCategory.where(feature_id: self.id).destroy_all
      CachedFeatureRelationCategory.where(related_feature_id: self.id).destroy_all

    	self.all_relations.each do |relation|
    		relation.child_node.feature_object_types.each do |fot|
    		  CachedFeatureRelationCategory.create({
    		    feature_id: relation.parent_node_id,
    		    related_feature_id: relation.child_node_id,
    		    category_id: fot.category_id,
    		    feature_relation_type_id: relation.feature_relation_type_id,
    		    feature_is_parent: true,
    		    perspective_id: relation.perspective_id
    		  })
    		end
    		parent_node = relation.parent_node
    		if !parent_node.nil?
    		  parent_node.feature_object_types.each do |fot|
      		  CachedFeatureRelationCategory.create({
      		    feature_id: relation.child_node_id,
      		    related_feature_id: relation.parent_node_id,
      		    category_id: fot.category_id,
      		    feature_relation_type_id: relation.feature_relation_type_id,
      		    feature_is_parent: false,
      		    perspective_id: relation.perspective_id
      		  })
      		end
  		  end
    	end
    end

    def category_count
      CategoryFeature.where(feature_id: self.id).count
    end
    
    def media_count(**options)
      media_count_hash = Rails.cache.fetch("#{self.cache_key}/media_count", expires_in: 1.day) do
        media_place_count = MmsIntegration::MediaPlaceCount.find(:all, params: {place_id: self.fid}).to_a
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
      ancestors = self.current_ancestors(KmapsEngine::ApplicationSettings.default_perspective_code)
      parent = ancestors.detect{|a| a.fid != self.fid && a.feature_object_types.detect{|ft| ft.category_id==29}}
      parent = self.parents.first if parent.nil?
      return parent
    end
    
    def calculate_prioritized_name(current_view)
      all_names = prioritized_names
      case current_view.code
      when 'roman.scholar'
        name = scholarly_prioritized_name(all_names)
      when 'pri.tib.sec.roman'
        name = tibetan_prioritized_name(all_names)
      when 'pri.tib.sec.chi'
        # If a writing system =tibt or writing system =Dzongkha name is available, show it
        name = tibetan_prioritized_name(all_names)
        name = FeatureExtensionForNamePositioning::HelperMethods.find_name_for_writing_system(all_names, WritingSystem.get_by_code('hans').id) if name.nil?
      when 'simp.chi'
        # If a writing system =hans name is available, show it
        name = FeatureExtensionForNamePositioning::HelperMethods.find_name_for_writing_system(all_names, WritingSystem.get_by_code('hans').id)
        name = FeatureExtensionForNamePositioning::HelperMethods.find_name_for_writing_system(all_names, WritingSystem.get_by_code('hant').id) if name.nil?
      when 'trad.chi'
        # If a writing system=hant name is available, show it
        name = FeatureExtensionForNamePositioning::HelperMethods.find_name_for_writing_system(all_names, WritingSystem.get_by_code('hant').id)
        name = FeatureExtensionForNamePositioning::HelperMethods.find_name_for_writing_system(all_names, WritingSystem.get_by_code('hans').id) if name.nil?
      when 'deva'
        # If a writing system =deva name is available, show it
        name = FeatureExtensionForNamePositioning::HelperMethods.find_name_for_writing_system(all_names, WritingSystem.get_by_code('deva').id)
      end
      name || popular_prioritized_name(all_names)
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
          FeatureRelation.where(parent_node_id: e.id).each do |r|
            c = r.child_node
            if !des_ids.include? c.id
              des_ids << c.id
              des << [c, e, r]
              pending.push(c)
            end
          end
        end
        topic_ids = topic_ids.first if topic_ids.size==1
        des_fids = des.collect{ |d| d.first.fid }
        sh_fids = Shape.find_by_sql('select fid from shapes where ST_INTERSECTS((SELECT ST_UNION(geometry) FROM shapes WHERE fid IN (2,428,430,431,432, 13734, 24107)), shapes.geometry)').collect(&:fid)
        des.uniq { |d| d.first.id }
        sh_fids.each do |fid|
          if !des_fids.include?(fid)
            f = Feature.get_by_fid(fid)
            if !f.nil?
              r = FeatureRelation.where(child_node_id: f.id).first
              e = r.nil? ? nil : r.parent_node
              des << [f, e, r]
            end
          end
        end
        des.select! { |d| !CumulativeCategoryFeatureAssociation.where(category_id: topic_ids, feature_id: d.first.id).first.nil? } if topic_ids != FeatureObjectType::BRANCH_ID
        des
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
          FeatureRelation.select('child_node_id').where(parent_node_id: e, feature_relation_type_id: FeatureRelationType.hierarchy_ids + [FeatureRelationType.get_by_code('is.contained.by').id]).each do |r|
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
      
      def faceted_descendants(**options)
        #fids, topic_ids, include_range, exclude_ranges
        fids = options[:fids]
        return nil if fids.nil?
        pending = fids.collect{|fid| Feature.get_by_fid(fid)}
        des = []
        while !pending.empty?
          e = pending.pop
          FeatureRelation.select('child_node_id').where(parent_node_id: e, feature_relation_type_id: FeatureRelationType.hierarchy_ids + [FeatureRelationType.get_by_code('is.contained.by').id]).each do |r|
            c = r.child_node_id
            if !des.include? c
              des << c
              pending.push(c)
            end
          end
        end
        topic_ids = options[:topic_ids]
        return des if topic_ids.nil?
        topic_ids = topic_ids.first if topic_ids.size==1
        include_range = options[:include_range]
        exclude_ranges = options[:exclude_ranges]
        res = ''
        des.select do |f_id|
          cfs = CategoryFeature.where(feature_id: f_id, category_id: topic_ids)
          if include_range.blank?
            !cfs.empty?
          else
            !cfs.index { |cf| !cf.time_units.index { |t| !t.nil? && t.between?(include_range[0], include_range[1]) && (exclude_ranges.blank? || exclude_ranges.index{|r| t.range_equal?(r)}.nil?) }.nil? }.nil?
          end
        end.collect do |f_id|
          Feature.find(f_id)
        end
      end
      
      def solr_url
        URI.join(PlacesIntegration::Feature.get_url, "solr/")
      end
    end
  end
end