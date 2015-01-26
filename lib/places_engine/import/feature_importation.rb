require 'kmaps_engine/import/feature_importation'

module PlacesEngine
  class FeatureImportation < KmapsEngine::FeatureImportation
    # Currently supported fields:
    # features.fid, features.old_pid, feature_names.delete, feature_names.is_primary.delete
    # i.feature_names.existing_name
    # i.feature_names.name, i.feature_names.position, i.feature_names.is_primary,
    # i.languages.code/name, i.writing_systems.code/name, i.alt_spelling_systems.code/name
    # i.phonetic_systems.code/name, i.orthographic_systems.code/name, BOTH DEPRECATED, INSTEAD USE: i.feature_name_relations.relationship.code
    # i.feature_name_relations.parent_node, i.feature_name_relations.is_translation, 
    # i.feature_name_relations.is_phonetic, i.feature_name_relations.is_orthographic, BOTH DEPRECATED AND USELESS
    # feature_types.delete, [i.]feature_types.id
    # i.geo_code_types.code/name, i.feature_geo_codes.geo_code_value, i.feature_geo_codes.info_source.id/code,
    # feature_relations.delete, [i.]feature_relations.related_feature.fid, [i.]feature_relations.type.code,
    # [i.]perspectives.code/name, feature_relations.replace
    # [i.]contestations.contested, [i.]contestations.administrator, [i.]contestations.claimant
    # i.kmaps.id, [i.]kXXX, kmaps.delete
    # [i.]shapes.lat, [i.]shapes.lng, [i.]shapes.altitude,
    # [i.]shapes.altitude.estimate, [i.]shapes.altitude.minimum, [i.]shapes.altitude.maximum,
    # [i.]shapes.altitude.average, [i.]shapes.altitude.delete
    # descriptions.delete, [i.]descriptions.title, [i.]descriptions.content, [i.]descriptions.author.fullname


    # Fields that accept time_units:
    # features, i.feature_names[.j], [i.]feature_types[.j], i.kmaps[.j], [i.]kXXX[.j], i.feature_geo_codes[.j], [i.]feature_relations[.j], [i.]shapes[.j]

    # time_units fields supported:
    # .time_units.[start.|end.]date, .time_units.[start.|end.]certainty_id, .time_units.season_id,
    # .time_units.calendar_id, .time_units.frequency_id

    # Fields that accept info_source:
    # [i.]feature_names[.j], [i.]feature_types[.j], i.feature_geo_codes[.j], [i.]kXXX[.j], i.kmaps[.j], [i.]feature_relations[.j], [i.]shapes[.j]

    # info_source fields:
    # .info_source.id/code, info_source.note
    # When info source is a document: .info_source[.i].volume, info_source[.i].pages
    # When info source is an online resource: .info_source[.i].path, .info_source[.i].name

    # Fields that accept note:
    # [i.]feature_names[.j], i.kmaps[.j], [i.]kXXX[.j], [i.]feature_types[.j], [i.]feature_relations[.j], [i.]shapes[.j], i.feature_geo_codes[.j]

    # Note fields:
    # .note

    def do_feature_import(filename, task_code)
      task = ImportationTask.find_by(task_code: task_code)
      task = ImportationTask.create(:task_code => task_code) if task.nil?
      self.spreadsheet = task.spreadsheets.find_by(filename: filename)
      self.spreadsheet = task.spreadsheets.create(:filename => filename, :imported_at => Time.now) if self.spreadsheet.nil?
      country_type = SubjectsIntegration::Feature.find(29)
      country_type_id = country_type.id
      current = 0
      feature_ids_with_changed_relations = Array.new
      feature_ids_with_object_types_added = Array.new
      puts "#{Time.now}: Starting importation."
      CSV.foreach(filename, headers: true, col_sep: "\t") do |row|
        self.fields = row.to_hash.delete_if{ |key, value| value.blank? }
        current+=1
        next unless self.get_feature(current)
        self.add_date('features', self.feature)
        self.process_names(44)
        self.process_kmaps(15)
        feature_ids_with_object_types_added += self.process_feature_types(4)
        self.process_geocodes(4)
        feature_ids_with_changed_relations += self.process_feature_relations(15)
        self.process_contestations(3)
        self.process_shapes(3)
        self.process_descriptions(3)
        self.feature.update_attributes({:is_blank => false, :is_public => true})
        #rescue  Exception => e
        #  puts "Something went wrong with feature #{self.feature.pid}!"
        #  puts e.to_s
        #end
        if self.fields.empty?
          puts "#{Time.now}: #{self.feature.pid} processed."
        else
          puts "#{Time.now}: #{self.feature.pid}: the following fields have been ignored: #{self.fields.keys.join(', ')}"
        end
      end
      puts "Updating cache..."
      # running triggers on feature_relation
      feature_ids_with_changed_relations.each do |id| 
        feature = Feature.find(id)
        #this has to be added to places dictionary!!!
        #feature.update_cached_feature_relation_categories
        feature.update_hierarchy
      end

      # running triggers for feature_object_type
      feature_ids_with_object_types_added.each do |id|
        feature = Feature.find(id)
        # have to add this to places dictionary!!!
        # feature.update_cached_feature_relation_categories if !feature_ids_with_changed_relations.include? id
        feature.update_object_type_positions
      end
      puts "#{Time.now}: Importation done."
    end    

    # The optional column "feature_types.id" can be used to specify the feature object type name.
    # If there is a category title, then optional columns are "categories.info_source.id" and
    # "categories.time_units.date".  
    def process_feature_types(n)
      feature_ids_with_object_types_added = Array.new
      delete_types = self.fields.delete('feature_types.delete')
      feature_object_types = self.feature.feature_object_types    
      feature_object_types.clear if !delete_types.blank? && delete_types.downcase == 'yes'
      0.upto(n) do |i|
        prefix = i>0 ? "#{i}.feature_types" : 'feature_types'
        feature_type_id = self.fields.delete("#{prefix}.id")
        next if feature_type_id.blank?
        category = SubjectsIntegration::Feature.find(feature_type_id)
        if category.nil?
          puts "Feature type #{feature_type_id} not found."
          next
        end
        feature_object_type = feature_object_types.find_by(category_id: category.id)
        if feature_object_type.nil?
          feature_object_type = feature_object_types.create(:category_id => category.id, :skip_update => true)
          self.spreadsheet.imports.create(:item => feature_object_type) if feature_object_type.imports.find_by(spreadsheet_id: self.spreadsheet.id).nil?
          feature_ids_with_object_types_added << self.feature.id if !feature_ids_with_object_types_added.include? self.feature.id
        end
        if feature_object_type.nil?
          puts "Couldn't associate feature type #{feature_type_id} to feature #{self.feature.pid}"
          next
        end
        self.add_date(prefix, feature_object_type)
        self.add_info_source(prefix, feature_object_type)
        self.add_note(prefix, feature_object_type)
        1.upto(8) do |j|
          field_prefix = "#{prefix}.#{j}"
          self.add_info_source(field_prefix, feature_object_type)
          self.add_date(field_prefix, feature_object_type)
          self.add_note(field_prefix, feature_object_type)
        end
      end
      return feature_ids_with_object_types_added
    end
    
    def process_contestations(n)
      # The optional column "contestations.contested" can specify "Yes" or "No". Optionally, you can also
      # include country names in "contestations.administrator" and "contestations.claimant"
      0.upto(n) do |i|
        prefix = i>0 ? "#{i}.contestations" : 'contestations'
        contested = self.fields.delete("#{prefix}.contested")
        next if contested.blank?
        administrator_name = self.fields.delete("#{prefix}.contestations.administrator")
        conditions = {}
        if administrator_name.blank?
          administrator = nil
        else
          administrator = Feature.where(['feature_names.name = ? AND feature_object_types.category_id = ?', administrator_name, country_type_id]).includes([:names, :feature_object_types]).references([:names, :feature_object_types]).first
          if administrator.nil?
            puts "Administrator country #{administrator_name} not found."
          else
            conditions[:administrator_id] = administrator.id
          end
        end
        claimant_name = self.fields.delete("#{prefix}.contestations.claimant")
        if claimant_name.blank?
          claimant = nil
        else
          claimant = Feature.includes([:names, :feature_object_types]).references([:names, :feature_object_types]).where(['feature_names.name = ? AND feature_object_types.category_id = ?', claimant_name, country_type_id]).first
          if claimant.nil?
            puts "Claimant country #{claimant_name} not found."
          else
            conditions[:claimant_id] = claimant.id
          end
        end
        contestations = self.feature.contestations
        contestation = contestations.find_by(conditions)
        if contestation.nil?
          contestation = contestations.create(:administrator_id => administrator.id, :claimant_id => claimant.id, :contested => (contested.downcase == 'yes'))
          self.spreadsheet.imports.create(:item => contestation) if contestation.imports.find_by(spreadsheet_id: self.spreadsheet.id).nil?
        end
        puts "Couldn't create contestation between #{claimant_name} and #{administrator_name} for #{self.feature.pid}." if contestation.nil?
      end
    end

    def process_shapes(n)
      # Deal with shapes
      0.upto(n) do |i|
        prefix = i>0 ? "#{i}.shapes" : 'shapes'
        shapes_lat = self.fields.delete("#{prefix}.lat")
        shapes_lng = self.fields.delete("#{prefix}.lng")
        if !shapes_lat.blank? && !shapes_lng.blank?
          shape = self.feature.shapes.detect do |s|
            g = s.geometry
            g.x == shapes_lng.to_f && g.y == shapes_lat.to_f
          end
          altitude = self.fields.delete("#{prefix}.altitude")
          if shape.nil?
            shape = Shape.new(:geometry => GeoRuby::SimpleFeatures::Point.new(4326), :fid => self.feature.fid, :altitude => altitude)
            geo = shape.geometry
            geo.y = shapes_lat
            geo.x = shapes_lng
            shape.geometry = geo
            shape.save
            if shape.id.nil?
              puts "Shape for feature #{self.feature.pid} could not be saved."
            end
          else
            shape.update_attribute(:altitude, altitude) if !altitude.blank? && shape.altitude != altitude
          end
          if !shape.nil?
            0.upto(3) do |j|
              second_prefix = j==0 ? prefix : "#{prefix}.#{j}"
              self.add_date(second_prefix, shape)
              self.add_note(second_prefix, shape)
              self.add_info_source(second_prefix, shape)
            end
          end
        else
          puts "Can't specify a latitude without a longitude and viceversa for feature #{self.feature.pid}" if !shapes_lat.blank? || !shapes_lng.blank?
        end
        # deal with "extra" altitudes
        estimate_str = self.fields.delete("#{prefix}.altitude.estimate")
        minimum_str = self.fields.delete("#{prefix}.altitude.minimum")
        maximum_str = self.fields.delete("#{prefix}.altitude.maximum")
        average_str = self.fields.delete("#{prefix}.altitude.average")
        if !estimate_str.blank? || !minimum_str.blank? || !maximum_str.blank? || !average_str.blank?
          altitudes = self.feature.altitudes
          delete_altitudes = self.fields.delete("#{prefix}.altitude.delete")
          conditions = {:unit_id => 1}
          conditions[:estimate] = estimate_str if !estimate_str.blank?
          conditions[:minimum] = minimum_str if !minimum_str.blank?
          conditions[:maximum] = maximum_str if !maximum_str.blank?
          conditions[:average] = average_str if !average_str.blank?
          if !delete_altitudes.blank? && delete_altitudes.downcase == 'yes'
            self.feature.shapes.each{ |s| s.update_attribute(:altitude, nil) }
            altitudes.clear
            altitude = altitudes.create(conditions)
            self.spreadsheet.imports.create(:item => altitude) if altitude.imports.find_by(spreadsheet_id: self.spreadsheet.id).nil?
          else
            altitude = altitudes.find_by(conditions)
            if altitude.nil?
              altitude = altitudes.create(conditions)
              self.spreadsheet.imports.create(:item => altitude) if altitude.imports.find_by(spreadsheet_id: self.spreadsheet.id).nil?
            end
          end        
        end
      end
    end

    def process_kmaps(n)
      # Now deal with i.kmaps.id
      category_features = self.feature.category_features
      delete_kmaps = self.fields.delete('kmaps.delete')
      category_features.clear if !delete_kmaps.blank? && delete_kmaps.downcase == 'yes'
      1.upto(n) do |i|
        kmap_prefix = "#{i}.kmaps"
        kmap_str = self.fields.delete("#{kmap_prefix}.id")
        next if kmap_str.blank?
        kmap = SubjectsIntegration::Feature.find(kmap_str.scan(/\d+/).first.to_i)
        if kmap.nil?
          puts "Could find kmap #{kmap_str} for feature #{self.feature.pid}."
          next
        end      
        conditions = { :category_id => kmap.id }
        category_feature = category_features.find_by(conditions)
        values = {}
        show_parent = self.fields.delete("#{kmap_prefix}.show_parent")
        values[:show_parent] = show_parent.downcase=='yes' if !show_parent.blank?
        show_root = self.fields.delete("#{kmap_prefix}.show_root")
        values[:show_root] = show_root.downcase=='yes' if !show_root.blank?
        if category_feature.nil?
          category_feature = category_features.create(conditions.merge(values))
        else
          category_feature.update_attributes(values)
        end
        self.spreadsheet.imports.create(:item => category_feature) if category_feature.imports.find_by(spreadsheet_id: self.spreadsheet.id).nil?
        next if category_feature.nil?
        0.upto(3) do |j|
          prefix = j==0 ? kmap_prefix : "#{kmap_prefix}.#{j}"
          self.add_date(prefix, category_feature)
          self.add_note(prefix, category_feature)
          self.add_info_source(prefix, category_feature)
        end
      end

      # now deal with [i.]kXXXX
      self.fields.keys.each do |key|
        next if key !~ /\A(\d+\.)?[kK]\d+\z/ # check to see if its a kmap
        value = self.fields.delete(key)
        next if value.nil?
        kmap_id = key.scan(/.*[kK](\d+)/).flatten.first.to_i
        kmap = SubjectsIntegration::Feature.find(kmap_id)
        if kmap.nil?
          puts "Could find kmap for #{kmap_id} associated with #{key} for #{self.feature.pid}."
          next
        end
        numeric_value = value.to_i
        if numeric_value.to_s == value
          string_value = nil
        else
          string_value = value
          numeric_value = nil
        end
        conditions = {:category_id => kmap.id}
        values = {:numeric_value => numeric_value, :string_value => string_value}
        show_parent = self.fields.delete("#{key}.show_parent")
        values[:show_parent] = show_parent.downcase=='yes' if !show_parent.blank?
        show_root = self.fields.delete("#{key}.show_root")
        values[:show_root] = show_root.downcase=='yes' if !show_root.blank?
        category_feature = category_features.find_by(conditions)
        if category_feature.nil?
          category_feature = category_features.create(conditions.merge(values))
        else
          category_feature.update_attributes(values)
        end
        self.spreadsheet.imports.create(:item => category_feature) if category_feature.imports.find_by(spreadsheet_id: self.spreadsheet.id).nil?
        0.upto(3) do |j|
          prefix = j==0 ? key : "#{key}.#{j}"
          self.add_date(prefix, category_feature)
          self.add_note(prefix, category_feature)
          self.add_info_source(prefix, category_feature)
        end      
      end

      self.fields.keys.each do |key|
        next if key !~ /\A[kK]\d+/ # check to see if its a kmap
        kmap_id = key.scan(/[kK](\d+)/).flatten.first.to_i
        pos = key =~ /time_units|note|info_source/
        if !pos.nil?
          kmap = SubjectsIntegration::Feature.find(kmap_id)
          if kmap.nil?
            puts "Could find kmap #{kmap_id} associated with #{key} for #{self.feature.pid}."
            next
          end
          conditions = { :category_id => kmap.id }
          category_feature = category_features.find_by(conditions)
          if category_feature.nil?
            category_feature = category_features.create(conditions)
            self.spreadsheet.imports.create(:item => category_feature) if category_feature.imports.find_by(spreadsheet_id: self.spreadsheet.id).nil?
          end
          prefix = key[0...pos-1]
          posfix = key[pos...key.size]
          next if category_feature.nil?
          0.upto(3) do |j|
            second_prefix = j==0 ? prefix : "#{prefix}.#{j}"
            self.add_date(second_prefix, category_feature)
            self.add_note(second_prefix, category_feature)
            self.add_info_source(second_prefix, category_feature)
          end        
        end
      end
    end
  end
end