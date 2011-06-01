require 'csv'
class Importation
  attr_accessor :feature, :fields
  
  def self.to_date(str)
    response = Hash.new
    array = str.split('/')
    response[:day] = array.shift.to_i if array.size==3
    response[:month] = array.shift.to_i if array.size>=2
    response[:year] = array.shift.to_i if array.size>=1
    response
  end
  
  def self.to_complex_date(str, certainty_id = nil, season_id = nil)
    complex_date = nil
    dash = str.index('-')
    if dash.nil?
      date = self.to_date(str)
      complex_date = ComplexDate.new(:day => date[:day], :day_certainty_id => certainty_id, :month => date[:month], :month_certainty_id => certainty_id, :year => date[:year], :year_certainty_id => certainty_id, :season_id => season_id, :season_certainty_id => certainty_id)
    else
      start_date = self.to_date(str[0...dash].strip)
      end_date = self.to_date(str[dash+1..str.size].strip)
      complex_date = ComplexDate.new(:day => start_date[:day], :day_end => end_date[:day], :day_certainty_id => certainty_id, :month => start_date[:month], :month_end => end_date[:month], :month_certainty_id => certainty_id, :year => start_date[:year], :year_end => end_date[:year], :year_certainty_id => certainty_id, :season_id => season_id, :season_certainty_id => certainty_id)
    end
    return complex_date
  end
  
  def self.say msg
    Rails.logger.info "IMPORTER COMMENT (#{Time.now.to_s}): #{msg}"
  end
  
  def self.content_attributes(object)
    h = object.attributes
    h.delete('id')
    h.delete('updated_at')
    h.delete('created_at')
    h
  end
  
  # Currently supported fields:
  # features.fid, features.old_pid, feature_names.delete, feature_names.is_primary.delete
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
  # [i.]descriptions.title, [i.]descriptions.content, [i.]descriptions.author.fullname
  

  # Fields that accept time_units:
  # features, i.feature_names[.j], [i.]feature_types[.j], i.kmaps[.j], [i.]kXXX[.j], i.feature_geo_codes[.j], [i.]feature_relations[.j], [i.]shapes[.j]

  # time_units fields supported:
  # .time_units.[start.|end.]date, .time_units.[start.|end.]certainty_id, .time_units.season_id,
  # .time_units.calendar_id, .time_units.frequency_id
  
  # Fields that accept info_source:
  # [i.]feature_names[.j], [i.]feature_types[.j], i.feature_geo_codes[.j], [i.]kXXX[.j], i.kmaps[.j], [i.]feature_relations[.j], [i.]shapes[.j]
  
  # info_source fields:
  # .info_source.id/code, info_source.notes, .info_source[.i].volume, info_source[.i].pages
  
  # Fields that accept note:
  # [i.]feature_names[.j], i.kmaps[.j], [i.]kXXX[.j], [i.]feature_types[.j], [i.]feature_relations[.j], [i.]shapes[.j]
  
  # Note fields:
  # .note
    
  def self.do_csv_import(filename)
    field_names = nil
    country_type = Category.find_by_title('Nation')
    country_type_id = country_type.id
    current = 0
    feature_ids_with_changed_relations = Array.new
    feature_ids_with_object_types_added = Array.new
    import = Importation.new
    puts "#{Time.now}: Starting importation."
    CSV.open(filename, 'r', "\t") do |row|
      current+=1
      if field_names.nil?
        field_names = row.collect{|c| c.blank? ? c : c.strip }
        next
      end
      import.populate_fields(row, field_names)
      next unless import.get_feature(current)
      #begin
        import.add_date('features', import.feature)
        import.process_names(44)
        import.process_kmaps(15)
        feature_ids_with_object_types_added += import.process_feature_types(4)
        import.process_geocodes(4)
        feature_ids_with_changed_relations += import.process_feature_relations(14)
        import.process_contestations(3)
        import.process_shapes(3)
        import.process_descriptions(3)
        import.feature.update_attributes({:is_blank => false, :is_public => true})
      #rescue  Exception => e
      #  puts "Something went wrong with feature #{import.feature.pid}!"
      #  puts e.to_s
      #end
      if import.fields.empty?
        puts "#{Time.now}: #{import.feature.pid} processed."
      else
        puts "#{Time.now}: #{import.feature.pid}: the following fields have been ignored: #{import.fields.keys.join(', ')}"
      end
    end
    puts "Updating cache..."
    # running triggers on feature_relation
    feature_ids_with_changed_relations.each do |id| 
      feature = Feature.find(id)
      feature.update_cached_feature_relation_categories
      feature.update_hierarchy
    end
    
    # running triggers for feature_object_type
    feature_ids_with_object_types_added.each do |id|
      feature = Feature.find(id)
      feature.update_cached_feature_relation_categories if !feature_ids_with_changed_relations.include? id
      feature.update_object_type_positions
    end
    puts "#{Time.now}: Importation done."
  end
    
  def add_date(field_prefix, dateable)
    date = self.fields.delete("#{field_prefix}.time_units.date")
    calendar_id = self.fields.delete("#{field_prefix}.time_units.calendar_id") || 1
    frequency_id = self.fields.delete("#{field_prefix}.time_units.frequency_id")
    season_id = self.fields.delete("#{field_prefix}.time_units.season_id")
    certainty_id = self.fields.delete("#{field_prefix}.time_units.certainty_id")
    if certainty_id.blank?
      start_certainty_id = self.fields.delete("#{field_prefix}.time_units.start.certainty_id")
      end_certainty_id = self.fields.delete("#{field_prefix}.time_units.end.certainty_id")          
    else
      start_certainty_id = certainty_id
      end_certainty_id = certainty_id
    end
    time_units = dateable.time_units
    if date.blank?
      start_date = self.fields.delete("#{field_prefix}.time_units.start.date")
      end_date = self.fields.delete("#{field_prefix}.time_units.end.date")
      if !start_date.blank? && !end_date.blank?
        if start_date==end_date
          complex_date = Importation.to_complex_date(start_date, start_certainty_id, season_id)
          if complex_date.nil?
            puts "Date #{date} could not be associated to #{dateable.class.class_name.titleize}."
          else
            if !time_units.blank?
              complex_date_attributes = Importation.content_attributes(complex_date)
              time_unit = time_units.detect{|t| Importation.content_attributes(t.date) == complex_date_attributes}
            end
            attrs = {:is_range => false, :calendar_id => calendar_id, :frequency_id => frequency_id}
            if time_unit.nil?
              time_unit = time_units.build(attrs.merge(:date => complex_date))
              if !time_unit.date.nil?
                time_unit.date.save
                time_unit.save
              end
            else
              time_unit.update_attributes(attrs)
            end
          end
        else
          complex_start_date = Importation.to_complex_date(start_date, start_certainty_id, season_id)
          complex_end_date = Importation.to_complex_date(end_date, end_certainty_id, season_id)
          if complex_start_date.nil? || complex_end_date.nil?
            puts "Date #{date} could not be associated to #{dateable.class_name.titleize}."
          else
            if !time_units.blank?
              complex_start_date_attributes = Importation.content_attributes(complex_start_date)
              complex_end_date_attributes = Importation.content_attributes(complex_end_date)
              time_unit = time_units.detect{|t| Importation.content_attributes(t.start_date) == complex_start_date_attributes && Importation.content_attributes(t.end_date) == complex_end_date_attributes}
            end
            attrs = {:is_range => true, :calendar_id => calendar_id, :frequency_id => frequency_id}
            if time_unit.nil?
              time_unit = dateable.time_units.build(attrs.merge(:start_date => complex_start_date, :end_date => complex_end_date))
              time_unit.start_date.save if !time_unit.start_date.nil?
              time_unit.end_date.save if !time_unit.end_date.nil?
              time_unit.save
            else
              time_unit.update_attributes(attrs)
            end
          end
        end
      else
        month = self.fields.delete("#{field_prefix}.time_units.month")
        day = self.fields.delete("#{field_prefix}.time_units.day")
        if month.blank? && day.blank?
          start_month = self.fields.delete("#{field_prefix}.time_units.start.month")
          start_day = self.fields.delete("#{field_prefix}.time_units.start.day")
          end_month = self.fields.delete("#{field_prefix}.time_units.end.month")
          end_day = self.fields.delete("#{field_prefix}.time_units.end.day")
          if (!start_month.blank? || !start_day.blank?) && (!end_month.blank? || !end_day.blank?)
            if start_day==end_day && start_month==end_month
              complex_date_attributes = {:day => start_day, :day_certainty_id => start_certainty_id, :month => start_month, :month_certainty_id => start_certainty_id, :season_id => season_id, :season_certainty_id => start_certainty_id}
              time_unit = time_units.detect{|t| Importation.content_attributes(t.date) == complex_date_attributes} if !time_units.blank?
              attrs = {:is_range => false, :calendar_id => calendar_id, :frequency_id => frequency_id}
              if time_unit.nil?
                complex_date = ComplexDate.create(complex_date_attributes)
                time_unit = dateable.time_units.build(attrs.merge(:date => complex_date))
                time_unit.save
              else
                time_unit.update_attributes(attrs)
              end
            else
              complex_start_date_attributes = {:day => start_day, :day_certainty_id => start_certainty_id, :month => start_month, :month_certainty_id => start_certainty_id, :season_id => season_id, :season_certainty_id => start_certainty_id}
              complex_end_date_attributes = {:day => end_day, :day_certainty_id => end_certainty_id, :month => end_month, :month_certainty_id => end_certainty_id, :season_id => season_id, :season_certainty_id => end_certainty_id}
              time_unit = time_units.detect{|t| Importation.content_attributes(t.start_date) == complex_start_date_attributes && Importation.content_attributes(t.end_date) == complex_end_date_attributes} if !time_units.blank?
              attrs = {:is_range => true, :calendar_id => calendar_id, :frequency_id => frequency_id}
              if time_unit.nil?
                complex_start_date = ComplexDate.create(complex_start_date_attributes)
                complex_end_date = ComplexDate.create(complex_end_date_attributes)
                time_unit = dateable.time_units.build(attrs.merge(:start_date => complex_start_date, :end_date => complex_end_date))
                time_unit.save
              else
                time_unit.update_attributes(attrs)
              end
            end
          end
        else
          complex_date_attributes = {:day => day, :day_certainty_id => certainty_id, :month => month, :month_certainty_id => certainty_id, :season_id => season_id, :season_certainty_id => certainty_id}
          time_unit = time_units.detect{|t| Importation.content_attributes(t.date) == complex_date_attributes} if !time_units.blank?
          attrs = {:is_range => false, :calendar_id => calendar_id, :frequency_id => frequency_id}
          if time_unit.nil?
            complex_date = ComplexDate.create(complex_date_attributes)
            time_unit = dateable.time_units.build(attrs.merge(:date => complex_date))
            time_unit.save
          else
            time_unit.update_attributes(attrs)
          end
        end
      end
    else
      complex_date = Importation.to_complex_date(date, certainty_id, season_id)
      if complex_date.nil?
        puts "Date #{date} could not be associated to #{dateable.class.class_name.titleize}."
      else
        if !time_units.blank?
          complex_date_attributes = Importation.content_attributes(complex_date)
          time_unit = time_units.detect{|t| Importation.content_attributes(t.date) == complex_date_attributes}
        end
        attrs = {:is_range => false, :calendar_id => calendar_id, :frequency_id => frequency_id}
        if time_unit.nil?
          time_unit = dateable.time_units.build(attrs.merge(:date => complex_date))
          if !time_unit.date.nil?
            time_unit.date.save
            time_unit.save
          end
        else
          time_unit.update_attributes(attrs)
        end
      end
    end            
  end
  
  def add_info_source(field_prefix, citable)
    info_source = nil
    begin
      info_source_id = self.fields.delete("#{field_prefix}.info_source.id")
      if info_source_id.blank?
        info_source_code = self.fields.delete("#{field_prefix}.info_source.code")
        if !info_source_code.blank?
          info_source = Document.find_by_original_medium_id(info_source_code)
          puts "Info source with code #{info_source_code} was not found." if info_source.nil?
        end
      else
        info_source = Document.find(info_source_id)
        puts "Info source with MMS ID #{info_source_id} was not found." if info_source.nil?
      end              
    rescue Exception => e
      puts e.to_s
    end            
    if !info_source.nil?
      notes = self.fields.delete("#{field_prefix}.info_source.notes")
      citations = citable.citations
      citation = citations.find(:first, :conditions => {:info_source_id => info_source.id})
      if citation.nil?
        citation = citations.create(:info_source => info_source, :notes => notes)
      else
        citation.update_attribute(:notes, notes) if !notes.nil?
      end
      if citation.nil?
        puts "Info source #{info_source.id} could not be associated to #{citable.class_name.titleize}."  
      else
        pages = citation.pages
        0.upto(2) do |j|
          prefix = j==0 ? "#{field_prefix}.info_source" : "#{field_prefix}.info_source.#{j}"
          volume_str = self.fields.delete("#{prefix}.volume")
          pages_range = self.fields.delete("#{prefix}.pages")
          if !volume_str.blank? || !pages_range.blank?
            volume = nil
            start_page = nil
            end_page = nil
            if !pages_range.blank?
              page_array = pages_range.split('-')
              start_page_str = page_array.shift
              end_page_str = page_array.shift
              start_page = start_page_str.to_i if !start_page_str.nil? && !start_page_str.strip!.blank?
              end_page = end_page_str.to_i if !end_page_str.nil? && !end_page_str.strip!.blank?
            end
            if !volume_str.blank?
              volume_str.strip!
              volume = volume_str.to_i if !volume_str.blank?
            end
            conditions = {:start_page => start_page, :end_page => end_page, :volume => volume}
            page = pages.find(:first, :conditions => conditions)
            page = pages.create(conditions) if page.nil?
          end
        end        
      end
    end  
  end
  
  def add_note(field_prefix, notable)
    note_str = self.fields.delete("#{field_prefix}.note")
    if !note_str.blank?
      notes = notable.notes
      note = notes.find(:first, :conditions => {:content => note_str})
      note = notes.create(:content => note_str) if note.nil?
      puts "Note #{note_str} could not be added to #{notable.class_name.titleize} #{notable.id}." if note.nil?
    end
  end
    
  def populate_fields(row, field_names)
    self.fields = Hash.new
    row.each_with_index do |field, index|
      if !field.nil?
        field.strip!
        self.fields[field_names[index]] = field if !field.empty?
      end
    end
  end

  # The feature can either be specified with by its current fid ("features.fid")
  # or the pid used in THL's previous application ("features.old_pid"). One of the two is required.  
  def get_feature(current)
    fid = self.fields.delete('features.fid')
    if fid.blank?
      old_pid = self.fields.delete('features.old_pid')
      if old_pid.blank?
        puts "Either a \"features.fid\" or a \"features.old_pid\" must be present in line #{current}!"
        return false
      end
      
      feature = Feature.find_by_old_pid(old_pid)
      if feature.nil?
        puts "Feature with old pid #{old_pid} was not found."
        return false
      end
    else
      feature = Feature.get_by_fid(fid)
      if feature.nil?
        puts "Feature with THL ID #{fid} was not found."
        return false
      end
    end
    self.feature = Feature.find(feature.id)
    return true
  end
  
  # Name is optional. If there is a name, then the required column (for i varying from
  # 1 to 18) is "i.feature_names.name".
  # Optional columns are "i.languages.code"/"i.languages.name",
  # "i.writing_systems.code"/"i.writing_systems.name",
  # "i.feature_names.info_source.id"/"i.feature_names.info_source.code"
  # and "i.feature_names.is_primary"
  # If optional column "i.feature_names.time_units.date" is specified, a date will be
  # associated to the name.
  # Additionally, optional column "i.feature_name_relations.parent_node" can be
  # used to establish name i as child of name j by simply specifying the name number.
  # The parent name has to precede the child name. If a parent column is specified,
  # the two optional columns can be included: "i.feature_name_relations.is_translation"
  # and "i.feature_name_relations.relationship.code" containing the code for the
  # phonetic or orthographic system.That is the prefered method
  # Alternatively, the following can still be used:
  # "i.phonetic_systems.code"/"i.phonetic_systems.name", 
  # "i.orthographic_systems.code"/"i.orthographic_systems.name",
  # You can also explicitly specify "i.feature_name_relations.is_phonetic" and
  # "i.feature_name_relations.is_orthographic" but it will
  # inferred otherwise.
  def process_names(total)
    names = self.feature.names
    prioritized_names = self.feature.prioritized_names
    # If feature_names.delete is "yes", all names and relations will be deleted.
    delete_feature_names = self.fields.delete('feature_names.delete')
    association_notes = self.feature.association_notes
    if !delete_feature_names.blank? && delete_feature_names.downcase == 'yes'
      names.clear
      association_notes.delete(association_notes.all(:conditions => {:association_type => "FeatureName"}))
    end
    name_added = false
    name_positions_with_changed_relations = Array.new
    relations_pending_save = Array.new
    name_changed = false
    
    delete_is_primary = self.fields.delete('feature_names.is_primary.delete')
    if !delete_is_primary.blank? && delete_is_primary.downcase == 'yes'
      names.all(:conditions => {:is_primary_for_romanization => true}).each do |name|
        name_changed = true if !name_changed
        name.update_attributes(:is_primary_for_romanization => false, :skip_update => true)
      end
    end    
    # feature_names.note can be used to add general notes to all names of a feature
    0.upto(3) do |i|
      feature_names_note = self.fields.delete(i==0 ? 'feature_names.note' : "feature_names.#{i}.note")
      if !feature_names_note.blank?
        note = association_notes.find(:first, :conditions => {:association_type => 'FeatureName', :content => feature_names_note })
        note = association_notes.create(:association_type => 'FeatureName', :content => feature_names_note) if note.nil?
        puts "Feature name note #{feature_names_note} could not be saved for feature #{self.feature.pid}" if note.nil?
      end
    end
    name = Array.new(total)
    1.upto(total) do |i|
      n = i-1
      name_str = self.fields.delete("#{i}.feature_names.name")
      next if name_str.blank?
      conditions = {:name => name_str}          
      begin
        language = Language.get_by_code_or_name(self.fields.delete("#{i}.languages.code"), self.fields.delete("#{i}.languages.name"))
      rescue Exception => e
        puts e.to_s
      end
      begin
        writing_system = WritingSystem.get_by_code_or_name(self.fields.delete("#{i}.writing_systems.code"), self.fields.delete("#{i}.writing_systems.name"))
        conditions[:writing_system_id] = writing_system.id if !writing_system.nil?
      rescue Exception => e
        puts e.to_s
      end
      begin
        alt_spelling_system = AltSpellingSystem.get_by_code_or_name(self.fields.delete("#{i}.alt_spelling_systems.code"), self.fields.delete("#{i}.alt_spelling_systems.name"))
      rescue Exception => e
        puts e.to_s
      end
      relationship_system_code = self.fields.delete("#{i}.feature_name_relations.relationship.code")
      if !relationship_system_code.blank?
        relationship_system = SimpleProp.get_by_code(relationship_system_code)
        if relationship_system.nil?
          puts "Phonetic or orthographic system with code #{relationship_system_code} was not found for feature #{self.feature.pid}."
        else
          if relationship_system.instance_of? OrthographicSystem
            orthographic_system = relationship_system
          elsif relationship_system.instance_of? PhoneticSystem
            phonetic_system = relationship_system
          else
            puts "Relationship #{relationship_system_code} has to be either phonetic or orthographic for feature #{self.feature.pid}."
          end
        end
      else
        begin
          orthographic_system = OrthographicSystem.get_by_code_or_name(self.fields.delete("#{i}.orthographic_systems.code"), self.fields.delete("#{i}.orthographic_systems.name"))
        rescue Exception => e
          puts e.to_s
        end
        begin
          phonetic_system = PhoneticSystem.get_by_code_or_name(self.fields.delete("#{i}.phonetic_systems.code"), self.fields.delete("#{i}.phonetic_systems.name"))
        rescue Exception => e
          puts e.to_s
        end
      end
      # if language is not specified it may be inferred.
      if language.nil?
        if phonetic_system.nil?
          language = Language.get_by_code('chi') if !writing_system.nil? && (writing_system.code == 'hant' || writing_system.code == 'hans')
        else
          language = Language.get_by_code('tib') if phonetic_system.code=='ethnic.pinyin.tib.transcrip' || phonetic_system.code=='tib.to.chi.transcrip'
        end
      end
      conditions[:language_id] = language.id if !language.nil?          
      name[n] = names.find(:first, :conditions => conditions)
      is_primary = self.fields.delete("#{i}.feature_names.is_primary")
      conditions[:is_primary_for_romanization] = is_primary.downcase=='yes' ? 1 : 0 if !is_primary.blank?
      relation_conditions = Hash.new
      relation_conditions[:orthographic_system_id] = orthographic_system.id if !orthographic_system.nil?
      relation_conditions[:phonetic_system_id] = phonetic_system.id if !phonetic_system.nil?
      relation_conditions[:alt_spelling_system_id] = alt_spelling_system.id if !alt_spelling_system.nil?
      position = self.fields.delete("#{i}.feature_names.position")
      if name[n].nil? || !relation_conditions.empty? && name[n].parent_relations.find(:first, :conditions => relation_conditions).nil?
        conditions[:position] = position if !position.blank?
        name[n] = names.create(conditions.merge({:skip_update => true}))
        name_added = true if !name_added && !name[n].id.nil?
      elsif !position.blank?
        name[n].update_attribute(:position, position)
        name_changed = true
      end
      if name[n].id.nil?
        puts "Name #{name_str} could not be added to feature #{self.feature.pid}."
        next
      end
      0.upto(4) do |j|
        prefix = j==0 ? "#{i}.feature_names" : "#{i}.feature_names.#{j}"
        self.add_date(prefix, name[n])
        self.add_info_source(prefix, name[n])
        self.add_note(prefix, name[n])
      end
      is_translation_str = self.fields.delete("#{i}.feature_name_relations.is_translation")
      is_translation = is_translation_str.downcase=='yes' ? 1: 0 if !is_translation_str.blank?
      parent_node_str = self.fields.delete("#{i}.feature_name_relations.parent_node")
      parent_name_str = self.fields.delete("#{i}.feature_name_relations.parent_node.name") if parent_node_str.blank?
      # for now is_translation is the only feature_name_relation that can be specified for a present or missing (inferred) parent.
      # if no parent is specified, it is possible to infer the parent based on the relationship to an already existing name.
      if parent_node_str.blank? && parent_name_str.blank?
        # tibetan must be parent
        if !phonetic_system.nil? && (phonetic_system.code=='ethnic.pinyin.tib.transcrip' || phonetic_system.code=='tib.to.chi.transcrip')
          parent_name = FeatureExtensionForNamePositioning::HelperMethods.find_name_for_writing_system(prioritized_names, WritingSystem.get_by_code('tibt').id)
          if parent_name.nil?
            puts "No tibetan name was found to associate #{phonetic_system.code} to #{name_str} for feature #{self.feature.pid}."
          else
            name_relation = name[n].parent_relations.find(:first, :conditions => {:parent_node_id => parent_name.id})
            if name_relation.nil?
              name_relation = name[n].parent_relations.create(:skip_update => true, :parent_node => parent_name, :phonetic_system => phonetic_system, :is_phonetic => 1, :is_translation => is_translation)
              if name_relation.nil?
                puts "Could not associate #{name_str} to Tibetan name for feature #{self.feature.pid}."
              else
                parent_name.update_hierarchy
                name_positions_with_changed_relations << n if !name_positions_with_changed_relations.include? n
              end
            else
              name_relation.update_attributes(:phonetic_system => phonetic_system, :is_phonetic => 1, :orthographic_system => nil, :is_orthographic => 0, :is_translation => is_translation)
            end
          end                
        end
        # now check if there is simplified chinese and make it a child of trad chinese
        writing_system = name[n].writing_system
        if !writing_system.nil? && writing_system.code=='hant'
          simp_chi_name = FeatureExtensionForNamePositioning::HelperMethods.find_name_for_writing_system(prioritized_names, WritingSystem.get_by_code('hans').id)
          if !simp_chi_name.nil?
            name_relation = simp_chi_name.parent_relations.first
            if name_relation.nil?
              name_relation = name[n].child_relations.create(:skip_update => true, :is_orthographic => 1, :orthographic_system => OrthographicSystem.get_by_code('trad.to.simp.ch.translit'), :is_translation => is_translation, :child_node => simp_chi_name)
              if name_relation.nil?
                puts "Could not make #{name_str} a parent of simplified chinese name for feature #{self.feature.pid}"
              else
                simp_chi_name.update_hierarchy
                name_positions_with_changed_relations << n if !name_positions_with_changed_relations.include? n
              end
            elsif !phonetic_system.nil? && phonetic_system.code=='tib.to.chi.transcrip'
              # only update if its tibetan
              name_relation.update_attributes(:phonetic_system => nil, :is_phonetic => 0, :orthographic_system => OrthographicSystem.get_by_code('trad.to.simp.ch.translit'), :is_orthographic => 1, :is_translation => is_translation, :parent_node => name[n])
            end
            # pinyin should be a child of the traditional and not the simplified chinese
            name_relation = simp_chi_name.child_relations.find(:first, :conditions => {:phonetic_system_id => PhoneticSystem.get_by_code('pinyin.transcrip')})
            name_relation.update_attribute(:parent_node, name[n]) if !name_relation.nil?
          end
        end
      else            
        conditions = {:skip_update => true, :phonetic_system => phonetic_system, :orthographic_system => orthographic_system, :is_translation => is_translation, :alt_spelling_system => alt_spelling_system}
        is_phonetic = self.fields.delete("#{i}.feature_name_relations.is_phonetic")
        if is_phonetic.blank?
          conditions[:is_phonetic] = phonetic_system.nil? ? 0 : 1
        else
          conditions[:is_phonetic] = is_phonetic.downcase=='yes' ? 1 : 0
        end
        is_orthographic = self.fields.delete("#{i}.feature_name_relations.is_orthographic")
        if is_orthographic.blank?
          conditions[:is_orthographic] = orthographic_system.nil? ? 0 : 1
        else
          conditions[:is_orthographic] = is_orthographic.downcase=='yes' ? 1: 0
        end
        is_alt_spelling = self.fields.delete("#{i}.feature_name_relations.is_alt_spelling")
        if is_alt_spelling.blank?
          conditions[:is_alt_spelling] = is_alt_spelling.nil? ? 0 : 1
        else
          conditions[:is_alt_spelling] = is_alt_spelling.downcase=='yes' ? 1: 0
        end
        if parent_node_str.blank?
          if !parent_name_str.blank?
            parent_name = prioritized_names.detect{|fn| fn.name==parent_name_str}
            if parent_name.nil?
              puts "Parent name #{parent_name_str} of #{name[n].name} for feature #{self.feature.pid} not found."
            else
              name << parent_name
              parent_position = name.size - 1
            end
          end
        else
          parent_position = parent_node_str.to_i-1
        end        
        relations_pending_save << { :relation => name[n].parent_relations.build(conditions), :parent_position => parent_position }
        name_positions_with_changed_relations << n if !name_positions_with_changed_relations.include? n
        name_positions_with_changed_relations << parent_position if !name_positions_with_changed_relations.include? parent_position
      end
    end
    relations_pending_save.each do |item|
      pending_relation = item[:relation]
      parent_node = name[item[:parent_position]]
      if parent_node.nil?
        puts "Parent name #{item[:parent_position]} of #{pending_relation.child_node.id} for feature #{self.feature.pid} not found."
      else
        relation = pending_relation.child_node.parent_relations.find(:first, :conditions => {:parent_node_id => parent_node.id})
        if relation.nil?
          pending_relation.parent_node = parent_node
          relation = pending_relation.save
          puts "Relation between names #{relation.child_note.name} and #{relation.parent_node.name} for feature #{self.feature.pid} could not be saved." if relation.nil?              
        end        
      end
    end
    
    # running triggers for feature_name
    self.feature.update_name_positions if name_added
    if name_added || name_changed
      self.feature.update_cached_feature_names
      self.feature.touch
    end
    
    # running triggers for feature_name_relation
    name_positions_with_changed_relations.each{|pos| name[pos].update_hierarchy if !name[pos].nil?}
  end

  # The optional column "feature_types.id" can be used to specify the feature object type name.
  # If there is a category title, then optional columns are "categories.info_source.id" and
  # "categories.time_units.date".  
  def process_feature_types(n)
    feature_ids_with_object_types_added = Array.new
    delete_types = self.fields.delete('feature_types.delete')
    self.feature.feature_object_types.clear if !delete_types.blank? && delete_types.downcase == 'yes'
    0.upto(n) do |i|
      prefix = i>0 ? "#{i}.feature_types" : 'feature_types'
      feature_type_id = self.fields.delete("#{prefix}.id")
      next if feature_type_id.blank?
      category = Category.find(feature_type_id)
      if category.nil?
        puts "Feature type #{feature_type_id} not found."
        next
      end
      feature_object_types = self.feature.feature_object_types
      feature_object_type = feature_object_types.find(:first, :conditions => {:category_id => category.id})
      if feature_object_type.nil?
        feature_object_type = feature_object_types.create(:category => category, :skip_update => true)
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
  
  # Up to four optional geocode types can be specified. For each geocode type the required columns are
  # "i.geo_code_types.code"/"i.geo_code_types.name" (where i can range between 1 and 4) and
  # "i.feature_geo_codes.geo_code_value".
  # The following optional columns are also accepted:
  # "i.feature_geo_codes.info_source.id"/"i.feature_geo_codes.info_source.code" and
  # "i.feature_geo_codes.time_units.date".
  def process_geocodes(n)
    1.upto(n) do |i|
      begin
        geocode_type = GeoCodeType.get_by_code_or_name(self.fields.delete("#{i}.geo_code_types.code"), self.fields.delete("#{i}.geo_code_types.name"))
      rescue Exception => e
        puts e.to_s
      end
      next if geocode_type.nil?
      geocode_value = self.fields.delete("#{i}.feature_geo_codes.geo_code_value")
      if geocode_value.blank?
        puts "Geocode value #{geocode_value} required for #{geocode_type.name}."
        next
      end
      geocodes = self.feature.geo_codes
      geocode = geocodes.find_by_geo_code_type_id(geocode_type.id)
      geocode = geocodes.create(:geo_code_type => geocode_type, :geo_code_value => geocode_value) if geocode.nil?
      if geocode.nil?
        puts "Couldn't associate #{geocode_value} to #{geocode_type} for feature #{self.feature.pid}"
        next
      end
      second_prefix = "#{i}.feature_geo_codes"
      0.upto(3) do |j|
        third_prefix = j==0 ? second_prefix : "#{second_prefix}.#{j}"
        self.add_date(third_prefix, geocode)
        self.add_info_source(third_prefix, geocode)
        self.add_note(third_prefix, geocode)
      end
    end
  end
  
  # The optional column "feature_relations.related_feature.fid" can specify the THL ID for parent feature.
  # If such parent is specified, the following columns are required:
  # "perspectives.code"/"perspectives.name", "feature_relations.type.code"
  def process_feature_relations(n)
    feature_ids_with_changed_relations = Array.new
    delete_relations = self.fields.delete('feature_relations.delete')
    if !delete_relations.blank? && delete_relations.downcase == 'yes'
      self.feature.all_child_relations.clear
      self.feature.all_parent_relations.clear
    end
    replace_relations_str = self.fields.delete('feature_relations.replace')
    if replace_relations_str.blank?
      replace_relation = false
    else
      replace_relations = replace_relations_str.downcase == 'yes'
    end
    0.upto(n) do |i|
      prefix = i>0 ? "#{i}." : ''
      parent_fid = self.fields.delete("#{prefix}feature_relations.related_feature.fid")
      next if parent_fid.blank?
      parent = Feature.get_by_fid(parent_fid)
      if parent.nil?
        puts "Parent feature with THL #{parent_fid} not found."
        next
      end
      perspective_code = self.fields.delete("#{prefix}perspectives.code")
      perspective_name = self.fields.delete("#{prefix}perspectives.name")
      perspective = nil
      if perspective_code.blank? && perspective_name.blank?
        if !replace_relations
          puts "Perspective type is required to establish a relationship between feature #{self.feature.pid} and feature #{parent_fid}."
          next
        end
      else
        begin
          perspective = Perspective.get_by_code_or_name(perspective_code, perspective_name)
        rescue Exception => e
          puts e.to_s
        end
        if perspective.nil?
          puts "Perspective #{perspective_code || perspective_name} was not found."
          next
        end
      end
      relation_type_str = self.fields.delete("#{prefix}feature_relations.type.code")
      relation_type = nil
      if relation_type_str.blank?
        if !replace_relations
          puts "Feature relation type is required to establish a relationship between feature #{self.feature.pid} and feature #{parent_fid}."
          next
        end
      else
        relation_type = FeatureRelationType.get_by_code(relation_type_str)
        if relation_type.nil?
          relation_type = FeatureRelationType.get_by_asymmetric_code(relation_type_str)
          if relation_type.nil?
            puts "Feature relation type #{relation_type_str} was not found."
            next
          else
            conditions = { :parent_node_id => self.feature.id, :child_node_id => parent.id }
          end
        else
          conditions = { :parent_node_id => parent.id, :child_node_id => self.feature.id }
        end
      end
      conditions.merge!(:feature_relation_type_id => relation_type.id, :perspective_id => perspective.id) if !replace_relations
      feature_relation = FeatureRelation.find(:first, :conditions => conditions)
      changed = false
      if feature_relation.nil?
        feature_relation = FeatureRelation.create(conditions.merge({:skip_update => true}))
        if feature_relation.nil?
          put "Failed to create feature relation between #{parent.pid} and #{self.feature.pid}"
        else
          changed = true
        end
      elsif replace_relations 
        feature_relation.feature_relation_type = relation_type if !relation_type.nil?
        feature_relation.perspective = perspective if !perspective.nil?
        if feature_relation.changed?
          feature_relation.skip_update = true
          feature_relation.save
          changed = true
        end
      end
      if changed
        feature_ids_with_changed_relations << parent.id if !feature_ids_with_changed_relations.include? parent.id
        feature_ids_with_changed_relations << self.feature.id if !feature_ids_with_changed_relations.include? self.feature.id
      end
      if feature_relation.nil?
        puts "Couldn't establish relationship #{relation_type_str} between feature #{self.feature.pid} and #{parent_fid}."
      else
        second_prefix = "#{prefix}feature_relations"
        0.upto(3) do |j|
          third_prefix = j==0 ? second_prefix : "#{second_prefix}.#{j}"
          self.add_date(third_prefix, feature_relation)
          self.add_info_source(third_prefix, feature_relation)
          self.add_note(third_prefix, feature_relation)
        end
      end
    end
    return feature_ids_with_changed_relations
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
        administrator = Feature.find(:first, :include => [:names, :feature_object_types], :conditions => ['feature_names.name = ? AND feature_object_types.category_id = ?', administrator_name, country_type_id])
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
        claimant = Feature.find(:first, :include => [:names, :feature_object_types], :conditions => ['feature_names.name = ? AND feature_object_types.category_id = ?', claimant_name, country_type_id])
        if claimant.nil?
          puts "Claimant country #{claimant_name} not found."
        else
          conditions[:claimant_id] = claimant.id
        end
      end
      contestations = self.feature.contestations
      contestation = contestations.find(:first, :conditions => conditions)
      contestation = contestations.create(:administrator => administrator, :claimant => claimant, :contested => (contested.downcase == 'yes')) if contestation.nil?
      puts "Couldn't create contestation between #{claimant_name} and #{administrator_name} for #{self.feature.pid}." if contestation.nil?
    end
  end
  
  # [i.]descriptions:
  # content, author.fullname  
  def process_descriptions(n)
    descriptions = self.feature.descriptions
    0.upto(n) do |i|
      prefix = i>0 ? "#{i}.descriptions" : 'descriptions'
      description_content = self.fields.delete("#{prefix}.content")
      if !description_content.blank?
        description_content = "<p>#{description_content}</p>"
        author_name = self.fields.delete("#{prefix}.author.fullname")
        author = author_name.blank? ? nil : User.find_by_fullname(author_name)
        description = descriptions.find_by_content(description_content) # : descriptions.find(:first, :conditions => ['LEFT(content, 200) = ?', description_content[0...200]])
        attributes = {:content => description_content, :title => self.fields.delete("#{prefix}.title")}
        if description.nil?
          description = descriptions.create(attributes)
        else
          description.update_attributes(attributes)
        end
        description.authors << author if !author.nil? && !description.author_ids.include?(author.id)
      end
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
        else
          altitude = altitudes.find(:first, :conditions => conditions)
          altitude = altitudes.create(conditions) if altitude.nil?
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
      kmap_str = self.fields.delete("#{i}.kmaps.id")
      next if kmap_str.blank?
      kmap = Category.find(kmap_str.scan(/\d+/).first.to_i)
      if kmap.nil?
        puts "Could find kmap #{kmap_str} for feature #{self.feature.pid}."
        next
      end      
      conditions = { :category_id => kmap.id }
      category_feature = category_features.find(:first, :conditions => conditions)
      category_feature = category_features.create(conditions) if category_feature.nil?
      next if category_feature.nil?
      0.upto(3) do |j|
        prefix = j==0 ? "#{i}.kmaps" : "#{i}.kmaps.#{j}"
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
      kmap = Category.find(kmap_id)
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
      category_feature = category_features.find(:first, :conditions => conditions)
      if category_feature.nil?
        category_feature = category_features.create(conditions.merge(values))
      else
        category_feature.update_attributes(values)
      end
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
        kmap = Category.find(kmap_id)
        if kmap.nil?
          puts "Could find kmap #{kmap_id} associated with #{key} for #{self.feature.pid}."
          next
        end
        conditions = { :category_id => kmap.id }
        category_feature = category_features.find(:first, :conditions => conditions)
        category_feature = category_features.create(conditions) if category_feature.nil?
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