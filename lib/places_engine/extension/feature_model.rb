module PlacesEngine
  module Extension
    module FeatureModel
      extend ActiveSupport::Concern
      include Rails.application.routes.url_helpers
      
      included do
        has_many :altitudes, dependent: :destroy
        has_many :category_features, dependent: :destroy
        has_many :contestations, dependent: :destroy
        has_many :cumulative_category_feature_associations, dependent: :destroy
        has_many :feature_object_types, -> { order :position }, dependent: :destroy
        has_many :shapes, foreign_key: 'fid', primary_key: 'fid'
        has_many :cached_feature_relation_categories, dependent: :destroy
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
        feature_id = Rails.cache.fetch("features/#{self.fid}/closest_feature_with_shapes", expires_in: 1.hour) do
          break self.id if self.has_shapes?(options)
          # check if geographical parent has shapes (township)
          geo_rel = Perspective.get_by_code('geo.rel')
          first_township_relation = self.all_parent_relations.find_by(perspective_id: geo_rel.id)
          if !first_township_relation.nil?
            node = first_township_relation.parent_node
            break node.id if node.has_shapes?(options)
          end
          # check if county parent has shapes (county)
          pol_admin = Perspective.get_by_code(KmapsEngine::ApplicationSettings.default_perspective_code)
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
        Feature.descendants_by_topic([self.fid], topic_ids)
      end
      
      def descendants_by_topic_with_parent(topic_ids)
        Feature.descendants_by_topic_with_parent([self.fid], topic_ids)
      end
      
      def faceted_descendants(options = Hash.new)
        Feature.faceted_descendants(options.merge(fids: [self.fid]))
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
      
      def media_count(options = {})
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
      
      def document_for_rsolr
        v = View.get_by_code(KmapsEngine::ApplicationSettings.default_view_code)
        per = Perspective.get_by_code(KmapsEngine::ApplicationSettings.default_perspective_code)

        object_types = self.object_types

        child_documents = object_types.collect do |ft|
          cd = { id: "#{self.uid}_featureType_#{ft.id}",
                 related_uid_s: "subjects-#{ft.id}",
                 origin_uid_s: self.uid,
                 feature_type_path_s: ft.ancestors.collect(&:id).join('/'),
                 block_child_type: ['feature_types'],
                 block_type: ['child'],
                 feature_type_name_s: ft.header,
                 related_names_t: ft.names.collect(&:name).uniq,
                 feature_type_id_i: ft.id,
                 feature_type_caption_s: ft.caption,
                 feature_type_caption_t: ft.nested_captions.collect(&:content)
               }
          cd[:feature_type_caption_s] = ft.caption.content if !ft.caption.nil?
          cd
        end
        
        category_features = self.category_features.where(type: nil)
        
        child_documents = child_documents + category_features.collect do |cf|
          c = cf.category
          next if c.nil?
          cd = { id: "#{self.uid}_relatedSubject_#{c.id}",
                 related_uid_s: "subjects-#{c.id}",
                 origin_uid_s: self.uid,
                 block_child_type: ['related_subjects'],
                 related_subjects_id_s: "subjects-#{c.id}",
                 related_subjects_header_s: c.header,
                 related_names_t: c.names.collect(&:name).uniq,
                 related_subjects_path_s: c.ancestors.collect(&:id).join('/'),
                 related_subjects_id_i: c.id,
                 related_subjects_caption_t: c.nested_captions.collect(&:content),
                 block_type: ['child'],
                 related_subjects_prefix_label_b: cf.prefix_label,
                 related_subjects_parent_show_b: cf.show_parent,
                 related_subjects_root_show_b: cf.show_root,
                 related_subjects_display_string_s: cf.display_string,
                 related_subjects_numeric_value_i: cf.numeric_value,
                 related_subjects_string_value_s: cf.string_value,
                 related_subjects_time_units_t: cf.time_units.collect(&:to_s)
               }
          cd[:related_subjects_caption_s] = c.caption.content if !c.caption.nil?
          cd[:related_subjects_parent_title_s] = c.parent.header if !c.parent.nil?
          cd
        end.compact
        
				parent_relations = self.all_parent_relations
				child_documents = child_documents + parent_relations.collect do |r|
          rf = r.parent_node
          related_subjects = rf.category_features.collect(&:category).select{|c| c}
          name = rf.prioritized_name(v)
          name_str = name.nil? ? nil : name.name
          all_feature_types = rf.feature_object_types.collect(&:category).select{|c| c}
          main_feature_type = all_feature_types.first
          relation_type = r.feature_relation_type
          label = relation_type.asymmetric_label
          label = relation_type.label if label.blank?
          { id: "#{self.uid}_#{relation_type.code}_#{rf.fid}",
            related_uid_s: rf.uid,
            origin_uid_s: self.uid,
            block_child_type: ['related_places'],
            related_places_id_s: "#{Feature.uid_prefix}-#{rf.fid}",
            related_places_header_s: name_str,
            related_names_t: rf.names.collect(&:name).uniq,
            related_places_path_s: rf.closest_ancestors_by_perspective(per).collect(&:fid).join('/'),
            related_places_feature_type_s: main_feature_type.nil? ? '' : main_feature_type.header,
            related_places_feature_type_id_i: main_feature_type.nil? ? nil : main_feature_type.id,
            related_subjects_t: related_subjects.collect(&:header),
            related_subject_ids: related_subjects.collect(&:id),
            related_places_feature_types_t: all_feature_types.collect(&:header),
            related_places_feature_type_ids: all_feature_types.collect(&:id),
            related_places_relation_label_s: label,
            related_places_relation_code_s: relation_type.code,
            related_kmaps_node_type: 'parent',
            block_type: ['child'] }
				end.flatten
        
				child_relations = self.all_child_relations
        child_documents = child_documents + child_relations.collect do |r|
          rf = r.child_node
          related_subjects = rf.category_features.collect(&:category).select{|c| c}
          name = rf.prioritized_name(v)
          name_str = name.nil? ? nil : name.name
          all_feature_types = rf.feature_object_types.collect(&:category).select{|c| c}
          main_feature_type = all_feature_types.first
          relation_type = r.feature_relation_type
          code = relation_type.asymmetric_code
          code = relation_type.code if code.blank?
          { id: "#{self.uid}_#{code}_#{rf.fid}",
            related_uid_s: rf.uid,
            origin_uid_s: self.uid,
            block_child_type: ['related_places'],
            related_places_id_s: "#{Feature.uid_prefix}-#{rf.fid}",
            related_places_header_s: name_str,
            related_names_t: rf.names.collect(&:name).uniq,
            related_places_path_s: rf.closest_ancestors_by_perspective(per).collect(&:fid).join('/'),
            related_places_feature_type_s: main_feature_type.nil? ? '' : main_feature_type.header,
            related_places_feature_type_id_i: main_feature_type.nil? ? nil : main_feature_type.id,
            related_subjects_t: related_subjects.collect(&:header),
            related_subject_ids: related_subjects.collect(&:id),
            related_places_feature_types_t: all_feature_types.collect(&:header),
            related_places_feature_type_ids: all_feature_types.collect(&:id),
            related_places_relation_label_s: relation_type.label,
            related_places_relation_code_s: code,
            related_kmaps_node_type: 'child',
            block_type: ['child'] }
        end.flatten
        associated_subjects = category_features.collect(&:category).compact

        child_documents = child_documents + self.altitudes.collect do |altitude|
          {id: "#{self.uid}_altitude_#{altitude.id}",
           block_child_type: ['places_altitude'],
           block_type: ['child'],
           maximum_i: altitude.maximum,
           minimum_i: altitude.minimum,
           average_i: altitude.average,
           estimate_s: altitude.estimate,
           unit_s: altitude.unit.title,
          }
        end
        child_documents = child_documents +
          self.shapes.where(is_public: true).collect do |shape|
          #self.shapes.where("is_public = true AND ST_GeometryType(geometry) != 'ST_Point'").collect do |shape|
            {id: "#{self.uid}_shape_#{shape.id}",
             block_child_type: ['places_shape'],
             block_type: ['child'],
             geometry_grptgeom: shape.as_geojson,
             geometry_type_s: shape.geo_type_text,
             area_f: shape.area,
             altitude_i: shape.altitude,
             position_i: shape.position,
            }
          end

        doc = { tree: 'places',
                feature_types: object_types.collect(&:header),
                feature_type_ids: object_types.collect(&:id),
                associated_subjects: associated_subjects.collect(&:header),
                associated_subject_ids: associated_subjects.collect(&:id),
                has_shapes: self.has_shapes?,
                has_altitudes: self.altitudes.count>0,
                block_type: ['parent'],
                '_childDocuments_' => child_documents }
        closest = self.closest_feature_with_shapes
        closest_fid = closest.nil? ? nil : closest.fid
        url = closest_fid.nil? ? nil : "#{InterfaceUtils::Server.get_thl_url}/places/maps/interactive/#fid:#{closest_fid}"
        doc[:interactive_map_url] = url unless url.nil?
        centroid = Shape.shapes_centroid_by_feature(self)
        doc[:shapes_centroid_grptgeom] = centroid unless centroid.nil?

        url = closest_fid.nil? ? nil : gis_resources_url(fids: closest_fid, host: InterfaceUtils::Server.get_url, format: 'kmz')
        doc[:kmz_url] = url unless url.nil?

        closest = self.closest_feature_with_shapes
        closest_fid = closest.nil? ? nil : closest.fid
        doc[:closest_fid_with_shapes] = closest_fid unless closest_fid.nil?
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
        
        def faceted_descendants(options = Hash.new)
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
      end
    end
  end
end
