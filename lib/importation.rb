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
  # 1.feature_names.name, 1.languages.code, 1.writing_systems.code, 1.feature_names.info_source.id, 1.feature_names.is_primary, 1.feature_names.time_units.date,
  # 1.feature_name_relations.parent_node, 1.feature_name_relations.is_translation, 1.feature_name_relations.relationship.code
  # feature_types.id, feature_types.info_source.id, feature_types.time_units.date
  # 1.geo_code_types.code, 1.feature_geo_codes.geo_code_value, 1.feature_geo_codes.info_source.id, 1.feature_geo_codes.time_units.date,
  # feature_relations.related_feature.fid, feature_relations.type.code, perspectives.code
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
      fid = fields['features.fid']
      if fid.blank?
        old_pid = fields['features.old_pid']
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
      delete_feature_names = fields['feature_names.delete']
      names.clear if !delete_feature_names.blank? && delete_feature_names.downcase == 'yes'
        
      # Name is optional. If there is a name, then the required column (for i varying from
      # 1 to 13) is "i.feature_names.name".
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
      name = Array.new(13)
      1.upto(13) do |i|
        n = i-1
        name_str = fields["#{i}.feature_names.name"]
        if !name_str.blank?
          conditions = {:name => name_str}          
          begin
            language = Language.get_by_code_or_name(fields["#{i}.languages.code"], fields["#{i}.languages.name"])
          rescue Exception => e
            puts e.to_s
          end
          begin
            writing_system = WritingSystem.get_by_code_or_name(fields["#{i}.writing_systems.code"], fields["#{i}.writing_systems.name"])
            conditions[:writing_system_id] = writing_system.id if !writing_system.nil?
          rescue Exception => e
            puts e.to_s
          end
          relationship_system_code = fields["#{i}.feature_name_relations.relationship.code"]
          if !relationship_system_code.blank?
            relationship_system = SimpleProp.get_by_code(relationship_system_code)
            if relationship_system.nil?
              puts "Phonetic or orthographic system with code #{relationship_system_code} was not found."
            else
              if relationship_system.instance_of? OrthographicSystem
                orthographic_system = relationship_system
              elsif relationship_system.instance_of? PhoneticSystem
                phonetic_system = relationship_system
              end
            end
          else
            begin
              orthographic_system = OrthographicSystem.get_by_code_or_name(fields["#{i}.orthographic_systems.code"], fields["#{i}.orthographic_systems.name"])
            rescue Exception => e
              puts e.to_s
            end
            begin
              phonetic_system = PhoneticSystem.get_by_code_or_name(fields["#{i}.phonetic_systems.code"], fields["#{i}.phonetic_systems.name"])
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
          is_primary = fields["#{i}.feature_names.is_primary"]
          conditions[:is_primary_for_romanization] = is_primary.downcase=='yes' ? 1 : 0 if !is_primary.blank?
          relation_conditions = Hash.new
          relation_conditions[:orthographic_system_id] = orthographic_system.id if !orthographic_system.nil?
          relation_conditions[:phonetic_system_id] = phonetic_system.id if !phonetic_system.nil?
          name[n] = names.create(conditions) if name[n].nil? || name[n].parent_relations.find(:first, :conditions => relation_conditions).nil?
          if name[n].id.nil?
            puts "Name #{name_str} could not be associated to feature #{feature.pid || feature.old_pid}."
          else
            date = fields["#{i}.feature_names.time_units.date"]          
            if !date.blank?
              complex_date = to_date(date)
              if complex_date.nil?
                puts "Date #{date} could not be associated to name #{name_str} of feature #{feature.pid || feature.old_pid}."
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
              info_source_id = fields["#{i}.feature_names.info_source.id"]
              if info_source_id.blank?
                info_source_code = fields["#{i}.feature_names.info_source.code"]
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
              citations.create(:info_source => info_source) if citation.nil?
            end
            
            is_translation_str = fields["#{i}.feature_name_relations.is_translation"]
            if !is_translation_str.blank?
              debugger
              is_translation = is_translation_str.downcase=='yes' ? 1: 0
            end
            parent_node_str = fields["#{i}.feature_name_relations.parent_node"]
            # for now is_translation is the only feature_name_relation that can be specified for a present or missing (inferred) parent.
            # if no parent is specified, it is possible to infer the parent based on the relationship to an already existing name.
            if parent_node_str.blank?
              feature_names = feature.prioritized_names
              # tibetan must be parent
              if !phonetic_system.nil? && (phonetic_system.code=='ethnic.pinyin.tib.transcrip' || phonetic_system.code=='tib.to.chi.transcrip')
                parent_name = FeatureExtensionForNamePositioning::HelperMethods.find_name_for_writing_system(feature_names, WritingSystem.get_by_code('tibt').id)
                if parent_name.nil?
                  puts "No tibetan name was found to associate #{phonetic_system.code} #{name[n]}."
                else
                  name_relation = name[n].parent_relations.find(:first, :conditions => {:parent_node_id => parent_name.id})
                  if name_relation.nil?
                    name[n].parent_relations.create(:parent_node => parent_name, :phonetic_system => phonetic_system, :is_phonetic => 1, :is_translation => is_translation)
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
                    name[n].child_relations.create(:is_orthographic => 1, :orthographic_system => OrthographicSystem.get_by_code('trad.to.simp.ch.translit'), :is_translation => is_translation, :child_node => simp_chi_name)
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
              parent_node = parent_node_str.to_i
              name_relation = name[n].parent_relations.find(:first, :conditions => {:parent_node_id => name[parent_node-1].id})
              if name_relation.nil?
                conditions = {:parent_node => name[parent_node-1], :phonetic_system => phonetic_system, :orthographic_system => orthographic_system, :is_translation => is_translation}
                is_phonetic = fields["#{i}.feature_name_relations.is_phonetic"]
                if is_phonetic.blank?
                  conditions[:is_phonetic] = phonetic_system.nil? ? 0 : 1
                else
                  conditions[:is_phonetic] = is_phonetic.downcase=='yes' ? 1 : 0
                end
                is_orthographic = fields["#{i}.feature_name_relations.is_orthographic"]
                if is_orthographic.blank?
                  conditions[:is_orthographic] = orthographic_system.nil? ? 0 : 1
                else
                  conditions[:is_orthographic] = is_orthographic.downcase=='yes' ? 1: 0
                end
                name[n].parent_relations.create(conditions)
              end
            end
          end
        end        
      end      
      
      # The optional column "categories.title" can be used to specify the feature object type name.
      # If there is a category title, then optional columns are "categories.info_source.id" and
      # "categories.time_units.date".
      category_title = fields['categories.title']
      if !category_title.blank?
        category = Category.find_by_title(category_title)
        if category.nil?
          puts "Category (feature object type) #{category_title} not found."
        else
          feature_object_types = feature.feature_object_types
          feature_object_type = feature_object_types.find(:first, :conditions => {:category_id => category.id})
          feature_object_type = feature_object_types.create(:category => category) if feature_object_type.nil?
          date = fields['categories.time_units.date']
          if !date.blank?
            complex_date = to_date(date)
            if complex_date.nil?
              puts "Date #{date} could not be associated to feature type #{category_title} of feature #{feature.pid || feature.old_pid}."
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
            info_source_id = fields['categories.info_source.id']
            if info_source_id.blank?
              info_source_code = fields['categories.info_source.code']
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
            citations.create(:info_source => info_source) if citation.nil?
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
          geocode_type = GeoCodeType.get_by_code_or_name(fields["#{i}.geo_code_types.code"], fields["#{i}.geo_code_types.name"])
        rescue Exception => e
          puts e.to_s
        end
        if !geocode_type.nil?
          geocode_value = fields["#{i}.feature_geo_codes.geo_code_value"]
          if geocode_value.blank?
            puts "Geocode value #{geocode_value} required for #{geocode_type.name}."
          else
            geocodes = feature.geo_codes
            geocode = geocodes.find_by_geo_code_type_id(geocode_type.id)
            if geocode.nil?
              geocode = geocodes.create(:geo_code_type => geocode_type, :geo_code_value => geocode_value)
              date = fields["#{i}.feature_geo_codes.time_units.date"]
              if !date.blank?
                complex_date = to_date(date)
                if complex_date.nil?
                  puts "Date #{date} could not be associated to geo_code #{geocode_value} (#{geocode_type}) of feature #{feature.pid || feature.old_pid}."
                else
                  time_unit = geocode.time_units.build(:date => complex_date, :is_range => false, :calendar_id => 1)
                  if !time_unit.date.nil?
                    time_unit.date.save
                    time_unit.save
                  end
                end                
              end
            end
            info_source = nil
            begin
              info_source_id = fields["#{i}.feature_geo_codes.info_source.id"]
              if info_source_id.blank?
                info_source_code = fields["#{i}.feature_geo_codes.info_source.code"]
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
              citations.create(:info_source => info_source) if citation.nil?
            end
          end
        end
      end
      
      # The optional column "feature_relations.related_feature.fid" can specify the THL ID for parent feature.
      # If such parent is specified, the following optional columns are accepted:
      # "perspectives.code"/"perspectives.name"
      # TODO: add feature relation type code.
      parent_fid = fields['feature_relations.related_feature.fid']
      if !parent_fid.blank?
        parent = Feature.get_by_fid(parent_fid)
        if parent.nil?
          puts "Parent feature with THL #{parent_fid} not found." 
        else
          begin
            perspective = Perspective.get_by_code_or_name(fields['perspectives.code'], fields['perspectives.name'])
          rescue Exception => e
            puts e.to_s
          end
          conditions = {:parent_node_id => parent.id, :child_node_id => feature.id}
          conditions[:perspective_id] = perspective.id if !perspective.nil?
          feature_relation = FeatureRelation.find(:first, :conditions => conditions)
          feature_relation = FeatureRelation.create(conditions) if feature_relation.nil?
        end
      end
      
      # The optional column "contestations.contested" can specify "Yes" or "No". Optionally, you can also
      # include country names in "contestations.administrator" and "contestations.claimant"
      contested = fields['contestations.contested']
      if !contested.blank?
        administrator_name = fields['contestations.administrator']
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
        claimant_name = fields['contestations.claimant']
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
        contestations.create(:administrator => administrator, :claimant => claimant, :contested => (contested.downcase == 'yes')) if contestation.nil?
      end
      feature.update_attributes({:is_blank => false, :is_public => true})
    end
  end
end