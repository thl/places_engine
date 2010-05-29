require 'csv'
module Importation
  
  def self.to_date(str)
    complex_date = nil
    begin
      date = str.to_date
      complex_date = ComplexDate.new(:day => date.day, :month => date.month, :year => date.year)
    rescue
      date_int = str.to_i
      complex_date = ComplexDate.new(:year => date_int) if date_int.to_s == str
    end
    return complex_date
  end
  
  # Fields in spreadsheet:
  # features.fid, features.old_pid, feature_names.delete,
  # 1.feature_names.name, 1.languages.code, 1.writing_systems.code, 
  # 1.feature_names.1.info_source.id, 1.feature_names.is_primary, 1.feature_names.1.time_units.date,
  # 1.feature_name_relations.parent_node, 1.feature_name_relations.is_translation, 1.feature_name_relations.relationship.code
  # 1.feature_types.id, 1.feature_types.1.info_source.id, 1.feature_types.1.time_units.date
  # 1.geo_code_types.code, 1.feature_geo_codes.geo_code_value, 1.feature_geo_codes.1.info_source.id, 1.feature_geo_codes.1.time_units.date,
  # 1.feature_relations.related_feature.fid, 1.feature_relations.type.code, 1.perspectives.code
  # 1.contestations.contested, 1.contestations.administrator, 1.contestations.claimant
  # shapes.lat	shapes.lng	shapes.altitude
  
  # New fields not in spreadsheet:
  # feature_names.note
  
  # Currently supported fields:
  # features.fid, features.old_pid, feature_names.delete, feature_names.note
  # i.feature_names.name, i.languages.code/i.languages.name, i.writing_systems.code/i.writing_systems.name,
  # i.feature_names.info_source.id/i.feature_names.info_source.code, i.feature_names.is_primary, i.feature_names.time_units.date
  # i.feature_name_relations.parent_node, i.feature_name_relations.is_translation, i.feature_name_relations.relationship.code
  # i.phonetic_systems.code/i.phonetic_systems.name, i.orthographic_systems.code/i.orthographic_systems.name, 
  # i.feature_name_relations.is_phonetic, i.feature_name_relations.is_orthographic
  # feature_types.id, categories.info_source.id, categories.time_units.date
  # i.geo_code_types.code/i.geo_code_types.name, i.feature_geo_codes.geo_code_value,
  # i.feature_geo_codes.info_source.id/i.feature_geo_codes.info_source.code, i.feature_geo_codes.time_units.date
  # feature_relations.related_feature.fid, feature_relations.type.code, perspectives.code/perspectives.name,
  # contestations.contested, contestations.administrator, contestations.claimant
  
  
  def self.do_csv_import(filename)
    field_names = nil
    country_type = Category.find_by_title('Nation')
    country_type_id = country_type.id
    current = 0
    CSV.open(filename, 'r', "\t") do |row|
      current+=1
      if field_names.nil?
        field_names = row
        next
      end
      fields = Hash.new
      row.each_with_index do |field, index|
        if !field.nil?
          field.strip!
          fields[field_names[index]] = field if !field.empty?
        end
      end
      # The feature can either be specified with by its current fid ("features.fid")
      # or the pid used in THL's previous application ("features.old_pid"). One of the two is required.
      fid = fields.delete('features.fid')
      if fid.blank?
        old_pid = fields.delete('features.old_pid')
        if old_pid.blank?
          puts "Either a\"features.fid\" or a \"features.old_pid\" must be present in line #{current}!"
          next
        else
          feature = Feature.find_by_old_pid(old_pid)
          if feature.nil?
            puts "Feature with old pid #{old_pid} was not found."
            next
          end
        end
      else
        feature = Feature.get_by_fid(fid)
        if feature.nil?
          puts "Feature with THL ID #{fid} was not found."
          next
        end
      end
      names = feature.names
      # If feature_names.delete is "yes", all names and relations will be deleted.
      delete_feature_names = fields.delete('feature_names.delete')
      names.clear if !delete_feature_names.blank? && delete_feature_names.downcase == 'yes'
      
      # feature_names.note can be used to add general notes to all names of a feature
      feature_names_note = fields.delete('feature_names.note')
      if !feature_names_note.blank?
        note = AssociationNote.find(:first, :conditions => { :notable_id => feature.id, :notable_type => 'Feature', :association_type => 'FeatureName', :content => feature_names_note })
        note = AssociationNote.create(:notable => feature, :association_type => 'FeatureName', :content => feature_names_note) if note.nil?
        puts "Feature name note #{feature_names_note} could not be saved for feature #{feature.pid}" if note.nil?
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
      relations_pending_save = Array.new
      name = Array.new(42)
      1.upto(42) do |i|
        n = i-1
        name_str = fields.delete("#{i}.feature_names.name")
        if !name_str.blank?
          conditions = {:name => name_str}          
          begin
            language = Language.get_by_code_or_name(fields.delete("#{i}.languages.code"), fields.delete("#{i}.languages.name"))
          rescue Exception => e
            puts e.to_s
          end
          begin
            writing_system = WritingSystem.get_by_code_or_name(fields.delete("#{i}.writing_systems.code"), fields.delete("#{i}.writing_systems.name"))
            conditions[:writing_system_id] = writing_system.id if !writing_system.nil?
          rescue Exception => e
            puts e.to_s
          end
          relationship_system_code = fields.delete("#{i}.feature_name_relations.relationship.code")
          if !relationship_system_code.blank?
            relationship_system = SimpleProp.get_by_code(relationship_system_code)
            if relationship_system.nil?
              puts "Phonetic or orthographic system with code #{relationship_system_code} was not found."
            else
              if relationship_system.instance_of? OrthographicSystem
                orthographic_system = relationship_system
              elsif relationship_system.instance_of? PhoneticSystem
                phonetic_system = relationship_system
              elsif relationship_system.instance_of? AltSpellingSystem
                alt_spelling_system = relationship_system
              end
            end
          else
            begin
              orthographic_system = OrthographicSystem.get_by_code_or_name(fields.delete("#{i}.orthographic_systems.code"), fields.delete("#{i}.orthographic_systems.name"))
            rescue Exception => e
              puts e.to_s
            end
            begin
              phonetic_system = PhoneticSystem.get_by_code_or_name(fields.delete("#{i}.phonetic_systems.code"), fields.delete("#{i}.phonetic_systems.name"))
            rescue Exception => e
              puts e.to_s
            end
            begin
              alt_spelling_system = AltSpellingSystem.get_by_code_or_name(fields.delete("#{i}.alt_spelling_systems.code"), fields.delete("#{i}.alt_spelling_systems.name"))
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
          is_primary = fields.delete("#{i}.feature_names.is_primary")
          conditions[:is_primary_for_romanization] = is_primary.downcase=='yes' ? 1 : 0 if !is_primary.blank?
          relation_conditions = Hash.new
          relation_conditions[:orthographic_system_id] = orthographic_system.id if !orthographic_system.nil?
          relation_conditions[:phonetic_system_id] = phonetic_system.id if !phonetic_system.nil?
          relation_conditions[:alt_spelling_system_id] = alt_spelling_system.id if !alt_spelling_system.nil?
          name[n] = names.create(conditions) if name[n].nil? || name[n].parent_relations.find(:first, :conditions => relation_conditions).nil?
          if name[n].id.nil?
            puts "Name #{name_str} could not be associated to feature #{feature.pid}."
          else
            date = fields.delete("#{i}.feature_names.time_units.date")          
            if !date.blank?
              complex_date = to_date(date)
              if complex_date.nil?
                puts "Date #{date} could not be associated to name #{name_str} of feature #{feature.pid}."
              else
                time_unit = name[n].time_units.build(:date => complex_date, :is_range => false, :calendar_id => 1)
                if !time_unit.date.nil?
                  time_unit.date.save
                  time_unit.save
                end
              end
            end
            info_source = nil
            begin
              info_source_id = fields.delete("#{i}.feature_names.info_source.id")
              if info_source_id.blank?
                info_source_code = fields.delete("#{i}.feature_names.info_source.code")
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
              citations = name[n].citations
              citation = citations.find(:first, :conditions => {:info_source_id => info_source.id})
              citation = citations.create(:info_source => info_source) if citation.nil?
              puts "Info source #{info_source.id} could not be associated to feature #{feature.pid}" if citation.nil?
            end
            
            is_translation_str = fields.delete("#{i}.feature_name_relations.is_translation")
            is_translation = is_translation_str.downcase=='yes' ? 1: 0 if !is_translation_str.blank?
            parent_node_str = fields.delete("#{i}.feature_name_relations.parent_node")
            # for now is_translation is the only feature_name_relation that can be specified for a present or missing (inferred) parent.
            # if no parent is specified, it is possible to infer the parent based on the relationship to an already existing name.
            if parent_node_str.blank?
              feature_names = feature.prioritized_names
              # tibetan must be parent
              if !phonetic_system.nil? && (phonetic_system.code=='ethnic.pinyin.tib.transcrip' || phonetic_system.code=='tib.to.chi.transcrip')
                parent_name = FeatureExtensionForNamePositioning::HelperMethods.find_name_for_writing_system(feature_names, WritingSystem.get_by_code('tibt').id)
                if parent_name.nil?
                  puts "No tibetan name was found to associate #{phonetic_system.code} to #{name_str} for feature #{feature.pid}."
                else
                  name_relation = name[n].parent_relations.find(:first, :conditions => {:parent_node_id => parent_name.id})
                  if name_relation.nil?
                    name_relation = name[n].parent_relations.create(:parent_node => parent_name, :phonetic_system => phonetic_system, :is_phonetic => 1, :is_translation => is_translation)
                    puts "Could not associate #{name_str} to Tibetan name for feature #{feature.pid}." if name_relation.nil?
                  else
                    name_relation.update_attributes(:phonetic_system => phonetic_system, :is_phonetic => 1, :orthographic_system => nil, :is_orthographic => 0, :is_translation => is_translation)
                  end
                end                
              end
              # now check if there is simplified chinese and make it a child of trad chinese
              writing_system = name[n].writing_system
              if !writing_system.nil? && writing_system.code=='hant'
                simp_chi_name = FeatureExtensionForNamePositioning::HelperMethods.find_name_for_writing_system(feature_names, WritingSystem.get_by_code('hans').id)
                if !simp_chi_name.nil?
                  name_relation = simp_chi_name.parent_relations.first
                  if name_relation.nil?
                    name_relation = name[n].child_relations.create(:is_orthographic => 1, :orthographic_system => OrthographicSystem.get_by_code('trad.to.simp.ch.translit'), :is_translation => is_translation, :child_node => simp_chi_name)
                    puts "Could not make #{name_str} a parent of simplified chinese name for feature #{f.pid}" if name_relation.nil?
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
              conditions = {:phonetic_system => phonetic_system, :orthographic_system => orthographic_system, :is_translation => is_translation, :alt_spelling_system => alt_spelling_system}
              is_phonetic = fields.delete("#{i}.feature_name_relations.is_phonetic")
              if is_phonetic.blank?
                conditions[:is_phonetic] = phonetic_system.nil? ? 0 : 1
              else
                conditions[:is_phonetic] = is_phonetic.downcase=='yes' ? 1 : 0
              end
              is_orthographic = fields.delete("#{i}.feature_name_relations.is_orthographic")
              if is_orthographic.blank?
                conditions[:is_orthographic] = orthographic_system.nil? ? 0 : 1
              else
                conditions[:is_orthographic] = is_orthographic.downcase=='yes' ? 1: 0
              end
              is_alt_spelling = fields.delete("#{i}.feature_name_relations.is_alt_spelling")
              if is_alt_spelling.blank?
                conditions[:is_alt_spelling] = is_alt_spelling.nil? ? 0 : 1
              else
                conditions[:is_alt_spelling] = is_alt_spelling.downcase=='yes' ? 1: 0
              end
              relations_pending_save << { :relation => name[n].parent_relations.build(conditions), :parent_position => parent_node_str.to_i-1 }
            end
          end
        end        
      end
      relations_pending_save.each do |item|
        pending_relation = item[:relation]
        parent_node = name[item[:parent_position]]
        relation = pending_relation.child_node.parent_relations.find(:first, :conditions => {:parent_node_id => parent_node.id})
        if relation.nil?
          pending_relation.parent_node = parent_node
          relation = pending_relation.save
          puts "Relation between names #{relation.child_note.name} and #{relation.parent_node.name} for feature #{feature.pid} could not be saved." if relation.nil?
        end        
      end
      
      # The optional column "feature_types.id" can be used to specify the feature object type name.
      # If there is a category title, then optional columns are "categories.info_source.id" and
      # "categories.time_units.date".
      feature_type_id = fields.delete('feature_types.id')
      if !feature_type_id.blank?
        category = Category.find(feature_type_id)
        if category.nil?
          puts "Feature type #{feature_type_id} not found."
        else
          feature_object_types = feature.feature_object_types
          feature_object_type = feature_object_types.find(:first, :conditions => {:category_id => category.id})
          feature_object_type = feature_object_types.create(:category => category) if feature_object_type.nil?
          if feature_object_type.nil?
            puts "Couldn't associate feature type #{feature_type_id} with feature #{f.pid}"
          else
            date = fields.delete('categories.time_units.date')
            if !date.blank?
              complex_date = to_date(date)
              if complex_date.nil?
                puts "Date #{date} could not be associated to feature type #{feature_type_id} of feature #{feature.pid}."
              else
                time_unit = feature_object_type.time_units.build(:date => complex_date, :is_range => false, :calendar_id => 1)
                if !time_unit.date.nil?
                  time_unit.date.save
                  time_unit.save
                end
              end            
            end
            info_source = nil
            begin
              info_source_id = fields.delete('categories.info_source.id')
              if info_source_id.blank?
                info_source_code = fields.delete('categories.info_source.code')
                if !info_source_code.blank?
                  info_source = Document.find_by_original_medium_id(info_source_code)
                  puts "Info source with code #{info_source_code} was not found." if info_source.nil?
                end              
              else
                info_source = Document.find(info_source_id)
                puts "Info source with id #{info_source_id} was not found." if info_source.nil?
              end              
            rescue Exception => e
              puts e.to_s
            end          
            if !info_source.nil?
              citations = feature_object_type.citations
              citation = citations.find(:first, :conditions => {:info_source_id => info_source.id})
              citation = citations.create(:info_source => info_source) if citation.nil?
              puts "Couldn't associate info source #{info_source_id} to feature type #{feature_type_id} for feature #{f.pid}" if citation.nil?
            end
          end
        end
      end
      
      # Up to four optional geocode types can be specified. For each geocode type the required columns are
      # "i.geo_code_types.code"/"i.geo_code_types.name" (where i can range between 1 and 4) and
      # "i.feature_geo_codes.geo_code_value".
      # The following optional columns are also accepted:
      # "i.feature_geo_codes.info_source.id"/"i.feature_geo_codes.info_source.code" and
      # "i.feature_geo_codes.time_units.date".
      1.upto(4) do |i|
        begin
          geocode_type = GeoCodeType.get_by_code_or_name(fields.delete("#{i}.geo_code_types.code"), fields.delete("#{i}.geo_code_types.name"))
        rescue Exception => e
          puts e.to_s
        end
        if !geocode_type.nil?
          geocode_value = fields.delete("#{i}.feature_geo_codes.geo_code_value")
          if geocode_value.blank?
            puts "Geocode value #{geocode_value} required for #{geocode_type.name}."
          else
            geocodes = feature.geo_codes
            geocode = geocodes.find_by_geo_code_type_id(geocode_type.id)
            if geocode.nil?
              geocode = geocodes.create(:geo_code_type => geocode_type, :geo_code_value => geocode_value)
              if geocode.nil?
                puts "Couldn't associate #{geocode_value} to #{geocode_type} for feature #{feature.pid}"
              else
                date = fields.delete("#{i}.feature_geo_codes.time_units.date")
                if !date.blank?
                  complex_date = to_date(date)
                  if complex_date.nil?
                    puts "Date #{date} could not be associated to geo_code #{geocode_value} (#{geocode_type}) of feature #{feature.pid}."
                  else
                    time_unit = geocode.time_units.build(:date => complex_date, :is_range => false, :calendar_id => 1)
                    if !time_unit.date.nil?
                      time_unit.date.save
                      time_unit.save
                    end
                  end                
                end
              end
            end
            info_source = nil
            begin
              info_source_id = fields.delete("#{i}.feature_geo_codes.info_source.id")
              if info_source_id.blank?
                info_source_code = fields.delete("#{i}.feature_geo_codes.info_source.code")
                if !info_source_code.blank?
                  info_source = Document.find_by_original_medium_id(info_source_code)
                  puts "Info source with code #{info_source_code} was not found." if info_source.nil?
                end
              else
                info_source = Document.find(info_source_id)
                puts "Info source with id #{info_source_id} was not found." if info_source.nil?
              end              
            rescue Exception => e
              puts e.to_s
            end
            if !info_source.nil?
              citations = geocode.citations
              citation = citations.find(:first, :conditions => {:info_source_id => info_source.id})
              citation = citations.create(:info_source => info_source) if citation.nil?
              puts "Couldn't associate info source #{info_source_id} to geocode #{geocode_value} (#{geocode_type}) for feature #{feature.pid}" if citation.nil?
            end
          end
        end
      end
      
      # The optional column "feature_relations.related_feature.fid" can specify the THL ID for parent feature.
      # If such parent is specified, the following columns are required:
      # "perspectives.code"/"perspectives.name", "feature_relations.type.code"
      parent_fid = fields.delete('feature_relations.related_feature.fid')
      if !parent_fid.blank?
        parent = Feature.get_by_fid(parent_fid)
        if parent.nil?
          puts "Parent feature with THL #{parent_fid} not found." 
        else
          begin
            perspective = Perspective.get_by_code_or_name(fields.delete('perspectives.code'), fields.delete('perspectives.name'))
          rescue Exception => e
            puts e.to_s
          end
          relation_type_str = fields.delete('feature_relations.type.code')
          if relation_type_str.blank?
            puts "Feature relation relation type is required to establish a relationship between feature #{feature.pid} and feature #{parent_fid}."
          else
            relation_type = FeatureRelationType.get_by_code(relation_type_str)
            if relation_type.nil?
              puts "Feature relation type #{relation_type_str} was not found."
            else
              conditions = {:parent_node_id => parent.id, :child_node_id => feature.id, :feature_relation_type_id => relation_type.id}
              conditions[:perspective_id] = perspective.id if !perspective.nil?
              feature_relation = FeatureRelation.find(:first, :conditions => conditions)
              feature_relation = FeatureRelation.create(conditions) if feature_relation.nil?
              puts "Couldn't establish relationship #{relation_type_str} between feature #{feature.pid} and #{parent_fid}." if feature_relation.nil?
            end
          end
        end
      end
      
      # The optional column "contestations.contested" can specify "Yes" or "No". Optionally, you can also
      # include country names in "contestations.administrator" and "contestations.claimant"
      contested = fields.delete('contestations.contested')
      if !contested.blank?
        administrator_name = fields.delete('contestations.administrator')
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
        claimant_name = fields.delete('contestations.claimant')
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
        contestations = feature.contestations
        contestation = contestations.find(:first, :conditions => conditions)
        contestation = contestations.create(:administrator => administrator, :claimant => claimant, :contested => (contested.downcase == 'yes')) if contestation.nil?
        puts "Couldn't create contestation between #{claimant_name} and #{administrator_name} for #{feature.pid}." if contestation.nil?
      end
      feature.update_attributes({:is_blank => false, :is_public => true})
      if fields.empty?
        puts "#{feature.pid} processed."
      else
        puts "#{feature.pid}: the following fields have been ignored: #{fields.keys.join(', ')}"
      end
    end
  end
end