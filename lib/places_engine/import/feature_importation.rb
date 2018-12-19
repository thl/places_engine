require 'kmaps_engine/import/feature_importation'

module PlacesEngine
  class FeatureImportation < KmapsEngine::FeatureImportation
    # Currently supported fields:
    # features.fid, features.old_pid, features.position, feature_names.delete, feature_names.is_primary.delete
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
    # descriptions.delete, [i.]descriptions.title, [i.]descriptions.content, [i.]descriptions.author.fullname, [i.]descriptions.language.code/name
    # [i.]captions:
    # content, author.fullname
    # [i.]summaries:
    # content, author.fullname

    # Fields that accept time_units:
    # features, i.feature_names[.j], [i.]feature_types[.j], i.kmaps[.j], [i.]kXXX[.j], i.feature_geo_codes[.j], [i.]feature_relations[.j], [i.]shapes[.j]

    # time_units fields supported:
    # .time_units.[start.|end.]date, .time_units.[start.|end.]certainty_id, .time_units.season_id,
    # .time_units.calendar_id, .time_units.frequency_id

    # Fields that accept info_source:
    # [i.]feature_names[.j], [i.]feature_types[.j], i.feature_geo_codes[.j], [i.]kXXX[.j], i.kmaps[.j],
    # [i.]feature_relations[.j], [i.]shapes[.j], [i.]summaries[.j]

    # info_source fields:
    # .info_source.id/code, info_source.note
    # When info source is a document: .info_source[.i].volume, info_source[.i].pages
    # When info source is an online resource: .info_source[.i].path, .info_source[.i].name
    # When info source is a oral source: .info_source.oral.fullname

    # Fields that accept note:
    # [i.]feature_names[.j], i.kmaps[.j], [i.]kXXX[.j], [i.]feature_types[.j], [i.]feature_relations[.j], [i.]shapes[.j], i.feature_geo_codes[.j]

    # Note fields:
    # .note, .title

    def do_feature_import(filename:, task_code:, from:, to:, log_level:)
      puts "#{Time.now}: Starting importation."
      task = ImportationTask.find_by(task_code: task_code)
      task = ImportationTask.create(:task_code => task_code) if task.nil?
      self.log = ActiveSupport::Logger.new("log/import_#{task_code}_#{Rails.env}.log")
      self.log.level = log_level.nil? ? Rails.logger.level : log_level.to_i
      self.log.debug { "#{Time.now}: Starting importation." }
      self.spreadsheet = task.spreadsheets.find_by(filename: filename)
      self.spreadsheet = task.spreadsheets.create(:filename => filename, :imported_at => Time.now) if self.spreadsheet.nil?
      interval = 100
      rows = CSV.read(filename, headers: true, col_sep: "\t")
      current = from.blank? ? 0 : from.to_i
      to_i = to.blank? ? rows.size : to.to_i
      ipc_reader, ipc_writer = IO.pipe('ASCII-8BIT')
      ipc_writer.set_encoding('ASCII-8BIT')
      puts "#{Time.now}: Processing features..."
      STDOUT.flush
      feature_ids_with_changed_relations = Array.new
      feature_ids_with_object_types_added = Array.new
      features_ids_to_cache = Array.new
      while current<to_i
        limit = current + interval
        limit = to_i if limit > to_i
        limit = rows.size if limit > rows.size
        sid = Spawnling.new do
          begin
            self.log.debug { "#{Time.now}: Spawning sub-process #{Process.pid}." }
            ipc_reader.close
            for i in current...limit
              row = rows[i]
              self.fields = row.to_hash.delete_if{ |key, value| value.blank? }
              self.fields.each_value(&:strip!)
              next unless self.get_feature(i+1)
              features_ids_to_cache << self.feature.id
              self.process_feature
              self.process_names(44)
              self.process_kmaps(15)
              feature_ids_with_object_types_added += self.process_feature_types(4)
              self.process_geocodes(5)
              feature_ids_with_changed_relations += self.process_feature_relations(15)
              self.process_contestations(3)
              self.process_shapes(3)
              self.process_descriptions(3)
              self.process_captions(2)
              self.process_summaries(2)
              self.feature.update_attributes({:is_blank => false, :is_public => true})
              self.progress_bar(num: i, total: to_i, current: self.feature.pid)
              #rescue  Exception => e
              #  puts "Something went wrong with feature #{self.feature.pid}!"
              #  puts e.to_s
              #end
              if self.fields.empty?
                self.log.debug { "#{Time.now}: #{self.feature.pid} processed." }
              else
                self.log.warn { "#{Time.now}: #{self.feature.pid}: the following fields have been ignored: #{self.fields.keys.join(', ')}" }
              end
            end
            ipc_hash = { for_relations: feature_ids_with_changed_relations, for_object_types: feature_ids_with_object_types_added,
              to_cache: features_ids_to_cache, bar: self.bar, num_errors: self.num_errors, valid_point: self.valid_point }
            data = Marshal.dump(ipc_hash)
            ipc_writer.puts(data.length)
            ipc_writer.write(data)
            ipc_writer.flush
            ipc_writer.close
          rescue Exception => e
            STDOUT.flush
            self.log.fatal { "#{Time.now}: An error occured when processing #{Process.pid}:" }
            self.log.fatal { e.message }
            self.log.fatal { e.backtrace.join("\n") }
          end
        end
        Spawnling.wait([sid])
        size = ipc_reader.gets
        data = ipc_reader.read(size.to_i)
        ipc_hash = Marshal.load(data)
        feature_ids_with_changed_relations = ipc_hash[:for_relations]
        feature_ids_with_object_types_added = ipc_hash[:for_object_types]
        features_ids_to_cache = ipc_hash[:to_cache]
        self.update_progress_bar(bar: ipc_hash[:bar], num_errors: ipc_hash[:num_errors], valid_point: ipc_hash[:valid_point])
        current = limit
      end
      ipc_writer.close
      sid = Spawnling.new do
        begin
          self.log.debug { "#{Time.now}: Spawning sub-process #{Process.pid}." }
          puts "#{Time.now}: Updating hierarchies for changed relations..."
          STDOUT.flush
          # running triggers on feature_relation
          feature_ids_with_changed_relations.uniq!
          self.log.debug { "#{Time.now}: Will update hierarchy for the following feature ids (NOT FIDS):\n#{feature_ids_with_changed_relations.to_s}." }
          features_ids_to_cache += feature_ids_with_changed_relations
          features_ids_to_cache.uniq!
          self.log.debug { "#{Time.now}: Will reindex the following feature ids (NOT FIDS):\n#{features_ids_to_cache.to_s}." }
          feature_ids_with_object_types_added.uniq!
          self.log.debug { "#{Time.now}: Will update object type positions for the following feature ids (NOT FIDS):\n#{feature_ids_with_object_types_added.to_s}." }
          feature_ids_with_changed_relations.each_index do |i|
            id = feature_ids_with_changed_relations[i]
            feature = Feature.find(id)
            #this has to be added to places dictionary!!!
            #feature.update_cached_feature_relation_categories
            feature.update_hierarchy
            self.progress_bar(num: i, total: feature_ids_with_changed_relations.size, current: feature.pid)
            self.log.debug { "#{Time.now}: Updated hierarchy for #{feature.fid}." }
          end
          puts "#{Time.now}: Updating object type positions..."
          STDOUT.flush
          # running triggers for feature_object_type
          feature_ids_with_object_types_added.each_index do |i|
            id = feature_ids_with_object_types_added[i]
            feature = Feature.find(id)
            # have to add this to places dictionary!!!
            # feature.update_cached_feature_relation_categories if !feature_ids_with_changed_relations.include? id
            feature.update_object_type_positions
            self.progress_bar(num: i, total: feature_ids_with_object_types_added.size, current: feature.pid)
            self.log.debug { "#{Time.now}: Updated object type positions for #{feature.fid}." }
          end
          puts "#{Time.now}: Reindexing changed features..."
          STDOUT.flush
          features_ids_to_cache.each_index do |i|
            id = features_ids_to_cache[i]
            feature = Feature.find(id)
            feature.index
            self.progress_bar(num: i, total: features_ids_to_cache.size, current: feature.pid)
            self.log.debug "#{Time.now}: Reindexed feature #{feature.fid}."
          end
          Feature.commit
          puts "#{Time.now}: Importation done."
          self.log.debug "#{Time.now}: Importation done."
          STDOUT.flush
        rescue Exception => e
          STDOUT.flush
          self.log.fatal { "#{Time.now}: An error occured when processing #{Process.pid}:" }
          self.log.fatal { e.message }
          self.log.fatal { e.backtrace.join("\n") }
        end
      end
      Spawnling.wait([sid])
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
          self.say "Feature type #{feature_type_id} not found."
          next
        end
        feature_object_type = feature_object_types.find_by(category_id: category.id)
        if feature_object_type.nil?
          feature_object_type = feature_object_types.create(:category_id => category.id, :skip_update => true)
          self.spreadsheet.imports.create(:item => feature_object_type) if feature_object_type.imports.find_by(spreadsheet_id: self.spreadsheet.id).nil?
          feature_ids_with_object_types_added << self.feature.id if !feature_ids_with_object_types_added.include? self.feature.id
        end
        if feature_object_type.nil?
          self.say "Couldn't associate feature type #{feature_type_id} to feature #{self.feature.pid}"
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
            self.say "Administrator country #{administrator_name} not found."
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
            self.say "Claimant country #{claimant_name} not found."
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
        self.say "Couldn't create contestation between #{claimant_name} and #{administrator_name} for #{self.feature.pid}." if contestation.nil?
      end
    end

    def process_shapes(n)
      # Deal with shapes
      0.upto(n) do |i|
        prefix = i>0 ? "#{i}.shapes" : 'shapes'
        gid = self.fields.delete("#{prefix}.gid")
        shapes_lat = self.fields.delete("#{prefix}.lat")
        shapes_lng = self.fields.delete("#{prefix}.lng")
        shape = gid.blank? ? nil : Shape.find(gid)
        if !shapes_lat.blank? && !shapes_lng.blank?
          lat_f = shapes_lat.to_f
          lng_f = shapes_lng.to_f
          if shape.nil?
            shape = self.feature.shapes.detect { |s| s.is_point? && s.lng == lng_f && s.lat == lat_f }
            if shape.nil?
              shape = Shape.create(:fid => self.feature.fid)
              Shape.where(:gid => shape.gid).update_all("geometry = ST_SetSRID(ST_MakePoint(#{shapes_lng}, #{shapes_lat}), 4326)")
            end
          else
            Shape.where(:gid => shape.gid).update_all("geometry = ST_SetSRID(ST_MakePoint(#{shapes_lng}, #{shapes_lat}), 4326)")
          end
        else
          self.say "Can't specify a latitude without a longitude and viceversa for feature #{self.feature.pid}" if !shapes_lat.blank? || !shapes_lng.blank?
        end
        next if shape.nil?
        altitude = self.fields.delete("#{prefix}.altitude")
        shape.update_attribute(:altitude, altitude) if !altitude.blank?
        0.upto(3) do |j|
          second_prefix = j==0 ? prefix : "#{prefix}.#{j}"
          self.add_date(second_prefix, shape)
          self.add_note(second_prefix, shape)
          self.add_info_source(second_prefix, shape)
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
          self.say "Could find kmap #{kmap_str} for feature #{self.feature.pid}."
          next
        end      
        values = { :category_id => kmap.id }
        # avoid checking first
        # category_feature = category_features.find_by(conditions)
        show_parent = self.fields.delete("#{kmap_prefix}.show_parent")
        values[:show_parent] = show_parent.downcase=='yes' if !show_parent.blank?
        show_root = self.fields.delete("#{kmap_prefix}.show_root")
        values[:show_root] = show_root.downcase=='yes' if !show_root.blank?
        #if category_feature.nil?
        category_feature = category_features.create(values)
        #else
          #category_feature.update_attributes(values)
        #end
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
          self.say "Could find kmap for #{kmap_id} associated with #{key} for #{self.feature.pid}."
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
            self.say "Could find kmap #{kmap_id} associated with #{key} for #{self.feature.pid}."
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
