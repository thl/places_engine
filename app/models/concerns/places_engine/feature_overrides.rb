module PlacesEngine
  module FeatureOverrides
    
    def nested_documents_for_rsolr
      v = View.get_by_code(KmapsEngine::ApplicationSettings.default_view_code)
      per = Perspective.get_by_code(KmapsEngine::ApplicationSettings.default_perspective_code)
      child_documents = self.feature_object_types.collect do |fot|
        ft = fot.category
        cd = { id: "#{self.uid}_featureType_#{ft.id}",
               related_uid_s: "subjects-#{ft.id}",
               origin_uid_s: self.uid,
               feature_type_path_s: ft.ancestors.collect(&:id).join('/'),
               block_child_type: ['feature_types'],
               block_type: ['child'],
               feature_type_name_s: ft.header,
               related_names_t: ft.names.collect(&:name).uniq,
               feature_type_id_i: ft.id,
               feature_type_caption_t: ft.nested_captions.collect(&:content)
        }
        prefix = 'feature_type'
        cd["#{prefix}_caption_s"] = ft.caption.content if !ft.caption.nil?
        citations = fot.citations
        citation_references = citations.collect { |c| c.bibliographic_reference }
        cd["#{prefix}_citation_references_ss"] = citation_references if !citation_references.blank?
        citations.each{ |ci| ci.rsolr_document_tags_for_notes(cd, prefix) }
        time_units = fot.time_units_ordered_by_date.collect { |t| t.to_s }
        cd["#{prefix}_time_units_ss"] = time_units if !time_units.blank?
        fot.notes.each { |n| n.rsolr_document_tags(cd, prefix) }
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
        }
        prefix = 'related_subjects'
        cd["#{prefix}_caption_s"] = c.caption.content if !c.caption.nil?
        cd["#{prefix}_parent_title_s"] = c.parent.header if !c.parent.nil?
        citations = cf.citations
        citation_references = citations.collect { |c| c.bibliographic_reference }
        cd["#{prefix}_citation_references_ss"] = citation_references if !citation_references.blank?
        citations.each{ |ci| ci.rsolr_document_tags_for_notes(cd, prefix) }
        time_units = cf.time_units_ordered_by_date.collect { |t| t.to_s }
        cd["#{prefix}_time_units_ss"] = time_units if !time_units.blank?
        cf.notes.each { |n| n.rsolr_document_tags(cd, prefix) }
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
        relation_tag = { id: "#{self.uid}_#{relation_type.code}_#{rf.fid}",
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
          related_places_relation_label_s: relation_type.is_symmetric ? relation_type.label : relation_type.asymmetric_label,
          related_places_relation_code_s: relation_type.code,
          related_kmaps_node_type: 'parent',
          block_type: ['child']
        }
        prefix = 'related_places'
        citations = r.citations
        citation_references = citations.collect { |c| c.bibliographic_reference }
        relation_tag["#{prefix}_citation_references_ss"] = citation_references if !citation_references.blank?
        citations.each{ |ci| ci.rsolr_document_tags_for_notes(relation_tag, prefix) }
        time_units = r.time_units_ordered_by_date.collect { |t| t.to_s }
        relation_tag["#{prefix}_time_units_ss"] = time_units if !time_units.blank?
        r.notes.each { |n| n.rsolr_document_tags(relation_tag, prefix) }
        relation_tag
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
        code = relation_type.is_symmetric ? relation_type.code : relation_type.asymmetric_code
        relation_tag = { id: "#{self.uid}_#{code}_#{rf.fid}",
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
          block_type: ['child']
        }
        prefix = 'related_places'
        citations = r.citations
        citation_references = citations.collect { |c| c.bibliographic_reference }
        relation_tag["#{prefix}_citation_references_ss"] = citation_references if !citation_references.blank?
        citations.each{ |ci| ci.rsolr_document_tags_for_notes(relation_tag, prefix) }
        time_units = r.time_units_ordered_by_date.collect { |t| t.to_s }
        relation_tag["#{prefix}_time_units_ss"] = time_units if !time_units.blank?
        r.notes.each { |n| n.rsolr_document_tags(relation_tag, prefix) }
        relation_tag
      end.flatten
      associated_subjects = category_features.collect(&:category).compact
      child_documents = child_documents + self.altitudes.collect do |altitude|
        altitude_tag = { id: "#{self.uid}_altitude_#{altitude.id}",
         block_child_type: ['places_altitude'],
         block_type: ['child'],
         maximum_i: altitude.maximum,
         minimum_i: altitude.minimum,
         average_i: altitude.average,
         estimate_s: altitude.estimate,
         unit_s: altitude.unit.title,
        }
        citations = altitude.citations.collect { |c| c.bibliographic_reference }
        altitude_tag['citation_references_ss'] = citations if !citations.blank?
        time_units = altitude.time_units_ordered_by_date.collect { |t| t.to_s }
        altitude_tag['time_units_ss'] = time_units if !time_units.blank?
        altitude.notes.each { |n| n.rsolr_document_tags(altitude_tag) }
        altitude_tag
      end
      shapes = self.shapes.where(is_public: true).select{|s| s.valid_range?}
      child_documents = child_documents + shapes.collect do |shape|
        #self.shapes.where("is_public = true AND ST_GeometryType(geometry) != 'ST_Point'").collect do |shape|
        shape_tag = { id: "#{self.uid}_shape_#{shape.id}",
          block_child_type: ['places_shape'],
          block_type: ['child'],
          geometry_rptgeom: shape.as_geojson,
          geometry_type_s: shape.geo_type_text,
          area_f: shape.area,
          altitude_i: shape.altitude,
          position_i: shape.position
        }
        citations = shape.citations.collect { |c| c.bibliographic_reference }
        shape_tag['citation_references_ss'] = citations if !citations.blank?
        time_units = shape.time_units_ordered_by_date.collect { |t| t.to_s }
        shape_tag['time_units_ss'] = time_units if !time_units.blank?
        shape.notes.each { |n| n.rsolr_document_tags(shape_tag) }
        shape_tag
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

      url = closest_fid.nil? ? nil : Rails.application.routes.url_helpers.gis_resources_url(fids: closest_fid, host: InterfaceUtils::Server.get_url, format: 'kmz')
      doc[:kmz_url] = url unless url.nil?

      closest = self.closest_feature_with_shapes
      closest_fid = closest.nil? ? nil : closest.fid
      doc[:closest_fid_with_shapes] = closest_fid unless closest_fid.nil?
      doc
    end
  end
end