module FeatureExtensionForNamePositioning
  def prioritized_name(current_view)
    view = current_view
    #feature_name_id = Rails.cache.fetch("#{self.cache_key}/#{view.cache_key}/prioritized_name") {
      cached_name = self.cached_feature_names.find(:first, :conditions => {:view_id => view.id})
      if cached_name.nil?
        calculated_name = self.calculate_prioritized_name(view)
        cached_name = self.cached_feature_names.create(:view => view, :feature_name => calculated_name) if !calculated_name.nil?
      end
      cached_name.nil? ? nil : cached_name.feature_name #_id
    #}
    # return feature_name_id.nil? ? nil : FeatureName.find(feature_name_id)
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
      name = HelperMethods.find_name_for_writing_system(all_names, WritingSystem.get_by_code('hans').id) if name.nil?
    when 'simp.chi'
      # If a writing system =hans name is available, show it
      name = HelperMethods.find_name_for_writing_system(all_names, WritingSystem.get_by_code('hans').id)
    when 'trad.chi'
      # If a writing system=hant name is available, show it
      name = HelperMethods.find_name_for_writing_system(all_names, WritingSystem.get_by_code('hant').id)
    when 'deva'
      # If a writing system =deva name is available, show it
      name = HelperMethods.find_name_for_writing_system(all_names, WritingSystem.get_by_code('deva').id)
    end
    name || popular_prioritized_name(all_names)
  end
  
  def tibetan_prioritized_name(all_names = prioritized_names)
    # If a writing system =tibt or writing system =Dzongkha name is available, show it
    HelperMethods.find_name_for_writing_system(all_names, WritingSystem.get_by_code('tibt').id) || HelperMethods.find_name_for_writing_system(all_names, WritingSystem.get_by_code('dzongkha').id)    
  end
  
  # Notice that this only includes the rules that are different from the popular view.  
  def scholarly_prioritized_name(all_names = prioritized_names)
    return nil if all_names.empty?
    # First check if its an exception
    name = all_names.detect{|n| n.is_primary_for_romanization?}
    return name if !name.nil?
    latin_id = WritingSystem.get_by_code('latin').id
    first_name = all_names.first    
    case first_name[:language_id]
    # language=tib: SHOW writing_systems=latn & orthographic_systems=thl.ext.wyl.translit
    when Language.get_by_code('tib').id
      name = HelperMethods.find_name_for_writing_and_orthographic_system(all_names, latin_id, OrthographicSystem.get_by_code('thl.ext.wyl.translit').id)
    # language=nep: SHOW writing_systems=latn & orthographic_systems=indo.standard.translit
    # language=hin: SHOW writing_systems=latn & orthographic_systems=indo.standard.translit
    when Language.get_by_code('nep').id, Language.get_by_code('hin').id
      name = HelperMethods.find_name_for_writing_and_orthographic_system(all_names, latin_id, OrthographicSystem.get_by_code('indo.standard.translit').id)

    # language=dzo: Right now we mostly have only the latin version of these names, which is marked as original. That is handled by popular view.
    # Later we will get the writing system=dzongkha or writing system=tibt version, and then this latin version will be demoted to a derivative of those dzongkha script names with writing system=latn, and orthographic_systems=thl.ext.wyl.translit
    # The new rule would look like this:
    # name = HelperMethods.find_name_for_writing_and_phonetic_system(all_names, latin_id, OrthographicSsytem.get_by_code('thl.ext.wyl.translit').id)  
    
    when Language.get_by_code('unk').id
      # language=unk; take in this order of preference, writing system=latn , original if its there,
      name = first_name if first_name[:writing_system_id] == latin_id
      return name if !name.nil?
      # and otherwise orthographic_systems=thl.ext.wyl.translit,
      name = HelperMethods.find_name_for_writing_and_orthographic_system(all_names, latin_id, OrthographicSystem.get_by_code('thl.ext.wyl.translit').id)
      return name if !name.nil?
      # pinyin
      name = HelperMethods.find_name_for_writing_and_phonetic_system(all_names, latin_id, PhoneticSystem.get_by_code('pinyin.transcrip').id)
      # orthographic_systems=indo_standard_translit
      name = HelperMethods.find_name_for_writing_and_orthographic_system(all_names, latin_id, OrthographicSystem.get_by_code('indo.standard.translit').id) if name.nil?
    end
    return name
  end
  
  def popular_prioritized_name(all_names = prioritized_names)
    return nil if all_names.empty?
    # First check if its an exception
    name = all_names.detect{|n| n.is_primary_for_romanization?}
    return name if !name.nil?
    latin_id = WritingSystem.get_by_code('latin').id
    first_name = all_names.first
    # language=eng, OR fre, OR ger, OR span, OR pol, OR lat, OR ita; SHOW the original name with writing system=latn
    if first_name.in_western_language? || first_name.in_language_without_transcription_system?
      name = Feature.find_name_for_writing_system(all_names, latin_id)
    else
      case first_name[:language_id]
      # language=chi: SHOW writing_systems=latn & phonetic_systems=pinyin.transcript
      when Language.get_by_code('chi').id
        name = HelperMethods.find_name_for_writing_and_phonetic_system(all_names, latin_id, PhoneticSystem.get_by_code('pinyin.transcrip').id)
      # language=tib: SHOW writing_systems=latn & phonetic_systems=thl.simple.transcrip
      when Language.get_by_code('tib').id
        name = HelperMethods.find_name_for_writing_and_phonetic_system(all_names, latin_id, PhoneticSystem.get_by_code('thl.simple.transcrip').id)
      # language=nep: SHOW writing_systems=latn & phonetic_systems=ind.transcrip.transcript
      # language=hin: SHOW writing_systems=latn & phonetic_systems=ind.transcrip.transcript
      when Language.get_by_code('nep').id, Language.get_by_code('hin').id
        name = HelperMethods.find_name_for_writing_and_phonetic_system(all_names, latin_id, PhoneticSystem.get_by_code('ind.transcrip').id)
      # language=dzo: Right now we mostly have only the latin version of these names, which is marked as original.
      when Language.get_by_code('dzo').id
        name = HelperMethods.find_name_for_writing_system(all_names, latin_id)
        # Later we will get the writing system=dzongkha or writing system=tibt version, and then this latin version will be demoted to a derivative of those dzongkha script names with writing system=latn , and phonetic_systems=dzo.to.eng.transcript
        # The new rule would look like this:
        # name = HelperMethods.find_name_for_writing_and_phonetic_system(all_names, latin_id, PhoneticSystem.get_by_code('dzo.to.eng.transcript').id)  
      # language=mon; writing_systems=latn
      when Language.get_by_code('mon').id
        # orthographic_systems=thl.mongol.translit
        name = HelperMethods.find_name_for_writing_and_orthographic_system(all_names, latin_id, OrthographicSystem.get_by_code('thl.mongol.translit').id)
        return name if !name.nil?
        # if doesn't exist then use orthographic_systems=thl.cyr.mongol.translit
        name = HelperMethods.find_name_for_writing_and_orthographic_system(all_names, latin_id, OrthographicSystem.get_by_code('thl.cyr.mongol.translit').id)
        return name if !name.nil?
        # if that doesn't exist orthographic_systems=loc.mongol.translit
        name = HelperMethods.find_name_for_writing_and_orthographic_system(all_names, latin_id, OrthographicSystem.get_by_code('thl.cyr.mongol.translit').id)
        # if that doesn't exist, orthographic_systems=loc.cyr.mongol.translit
        name = HelperMethods.find_name_for_writing_and_orthographic_system(all_names, latin_id, OrthographicSystem.get_by_code('loc.cyr.mongol.translit').id) if name.nil?
      when Language.get_by_code('unk').id
        # language=unk; take in this order of preference, writing system=latn , original if its there,
        name = first_name if first_name[:writing_system_id] == latin_id
        return name if !name.nil?
        # and otherwise phonetic_systems=thl_simple_transcrip, 
        name = HelperMethods.find_name_for_writing_and_phonetic_system(all_names, latin_id, PhoneticSystem.get_by_code('thl.simple.transcrip').id)
        return name if !name.nil?
        # pinyin
        name = HelperMethods.find_name_for_writing_and_phonetic_system(all_names, latin_id, PhoneticSystem.get_by_code('pinyin.transcrip').id)
        # ind.transcrip
        name = HelperMethods.find_name_for_writing_and_phonetic_system(all_names, latin_id, PhoneticSystem.get_by_code('ind.transcrip').id) if name.nil?
      end
    end
    # If there is no such name available, show the highest priority form of any type that has writing_systems=latn
    # If there is no writing_systems=latn, display "Unknown"
    name || HelperMethods.find_name_for_writing_system(all_names, latin_id)
  end
  
  def prioritized_names
    Rails.cache.fetch("#{self.cache_key}/prioritized_names") { self.names.find(:all, :order => 'position') }
  end
  
  #
  # Join all of the FeatureNames together
  #
  def name(sep=', ')
    Rails.cache.fetch("#{self.cache_key}/combined_name") { self.names.size > 0 ? prioritized_names.collect(&:name).join(sep) : self.pid }
  end
  
  def calculate_name_positions(names = self.names.roots(:order => 'feature_names.created_at'), position = 1)
    sorted_names = Hash.new
    if names.size == 1
      # If there is only one name tree, it will be automatically assigned priority=1 value without need from editor.
      name = names.first
      sorted_names[position] = name
      position += 1
    else
      if names.size > 1
        # Priority 1 for a name tree would be assigned by default to the one with the top level name that has the
        # language corresponding to the nation (Chinese for China, Nepal for Nepal, Dzongkha for Bhutan, Hindi for
        # India, etc.)
        # This would be superceded for top level names with language=Tibetan for TAR, Qinghai, Gansu, Sichuan, and
        # Yunnan in China
        name = self.figure_out_name_by_country(names)
        #If there is no parent Nation, then priority 1 will for whichever name tree was first entered in terms of data entry
        name = names.shift if name.nil?
        sorted_names[position] = name
        position += 1

        # Priority 2 for a name tree would be assigned by default to the name tree with the top level name that has
        # the language corresponding to English (if there is one)
        name = HelperMethods.figure_out_name_by_language_code(names, 'eng')
        if !name.nil?
          sorted_names[position] = name
          position += 1
        end

        # All other determinations of priority between name trees will be made in terms of the order of the name trees being created
        # Within a single name tree, the only thing I can think of is to assign priority in the order of data entry
        names.each do |name|
          sorted_names[position] = name
          position += 1
        end
      end
    end
    sorted_names.keys.sort.inject(sorted_names.dup) {|names, i| names.merge(calculate_name_positions(sorted_names[i].children.find(:all, :order => 'feature_names.created_at'), names.keys.max + 1)) }
  end
  
  def update_is_name_position_overriden
    hash = self.calculate_name_positions
    calculated_order = hash.keys.sort.collect{|i| hash[i].id}
    current_order = self.prioritized_names.collect(&:id)
    self.is_name_position_overriden = current_order != calculated_order
    self.save
  end
  
  def update_name_positions
    if self.is_name_position_overriden?
      names = self.names
      self.names.find(:all, :conditions => {:position => 0}, :order => 'created_at').inject(names.maximum(:position)+1) do |pos, name|
        name.update_attribute(:position, pos)
        pos + 1
      end
    else
      self.reset_name_positions
    end
  end
  
  def update_cached_feature_names
    cached_names = self.cached_feature_names
    # First expire rails cache
    Rails.cache.delete("#{self.cache_key}/prioritized_names")
    View.get_all.each do |view|
      calculated_name = self.calculate_prioritized_name(view)
      cached_name = cached_names.find(:first, :conditions => {:view_id => view.id})
      if cached_name.nil?
        cached_names.create(:view => view, :feature_name => calculated_name)
      else
        if cached_name.feature_name != calculated_name
          cached_name.update_attribute(:feature_name, calculated_name)
          # Expire the names that have changed
          Rails.cache.delete("#{self.cache_key}/#{view.cache_key}/prioritized_name")
        end
      end
    end
  end
  
  def reset_name_positions(names = self.names.roots(:order => 'feature_names.created_at'), position = 1)
    calculate_name_positions(names, position).each { |pos, name| name.update_attribute(:position, pos) }
  end
  
  def figure_out_name_by_country(names)
    # order matters, that is why I am using ancestor_ids instead of ancestors
    ordered_ancestors = self.ancestor_ids.blank? ? [] : self.ancestor_ids.split('.').delete_if{|id| id.blank?}.collect(&:to_i)
    id = ([self.fid] + ordered_ancestors).detect{|id| HelperMethods::LANG_CODES_BY_FEATURE_IDS[id]}
    return nil if id.nil?
    HelperMethods.figure_out_name_by_language_code(names, HelperMethods::LANG_CODES_BY_FEATURE_IDS[id])
  end
  
  def restructure_chinese_names
    all_names = prioritized_names
    trad_chi_name = HelperMethods.find_name_for_writing_system(all_names, WritingSystem.get_by_code('hant').id)
    simp_chi_name = HelperMethods.find_name_for_writing_system(all_names, WritingSystem.get_by_code('hans').id)
    return false if trad_chi_name.nil? || simp_chi_name.nil? || !simp_chi_name.parent_relations.empty?
    FeatureNameRelation.create :is_orthographic => 1, :orthographic_system => OrthographicSystem.get_by_code('trad.to.simp.ch.translit'), :parent_node => trad_chi_name, :child_node => simp_chi_name
    return true
    #|| parent_rel.parent_node_id != trad_chi_name.id
    #pinyin_trad_rel = trad_chi_name.child_relations.detect{|r| r.phonetic_system_id==pinyin_id}
    #pinyin_simp_rel = simp_chi_name.child_relations.detect{|r| r.phonetic_system_id==pinyin_id}
    #!pinyin_simp_rel.nil? && pinyin_trad_rel.nil?
  end
    
  def self.included(base)
    base.extend ClassMethods
  end
  
  module ClassMethods
    def reset_name_positions
      self.find(:all).each { |f| f.reset_name_positions }
    end

    def restructure_chinese_names
      self.find(:all).select { |f| f.restructure_chinese_names }
    end
        
    def reset_positions
      self.find(:all).reject { |f| f.prioritized_name.nil? }.sort_by(&:prioritized_name).each_with_index{|f, i| f.update_attribute(:position,i+1)}
    end
    
    def update_cached_feature_names
      self.find(:all, :order => 'fid').each { |f| f.update_cached_feature_names }
    end
  end
  
  module HelperMethods
    LANG_CODES_BY_FIDS = {5244 => 'urd', 427 => 'dzo', 426 => 'nep', 425 => 'hin', 2 => 'tib', 431 => 'tib', 432 => 'tib', 428 => 'tib', 430 => 'tib', 1 => 'chi'}
    LANG_CODES_BY_FEATURE_IDS = {}
    LANG_CODES_BY_FIDS.each_key{|fid| LANG_CODES_BY_FEATURE_IDS[Feature.find_by_fid(fid).id] = LANG_CODES_BY_FIDS[fid] }
    
    def self.find_name_for_writing_system(names, writing_system_id)
      names.detect{|n| n[:writing_system_id]==writing_system_id}
    end

    def self.find_name_for_writing_and_phonetic_system(names, writing_system_id, phonetic_system_id)
      find_name_for_writing_and_relational_system(names, writing_system_id, :phonetic_system_id, phonetic_system_id)
    end

    def self.find_name_for_writing_and_orthographic_system(names, writing_system_id, orthographic_system_id)
      find_name_for_writing_and_relational_system(names, writing_system_id, :orthographic_system_id, orthographic_system_id)
    end  

    def self.find_name_for_writing_and_relational_system(names, writing_system_id, system_name, system_id)
      names.detect do |n|
        if n[:writing_system_id]==writing_system_id
          parent_relation = n.parent_relations.first
          !parent_relation.nil? && parent_relation[system_name]==system_id
        else
          false
        end
      end
    end
    
    def self.figure_out_name_by_language_code(names, language_code)
      language_id = Language.get_by_code(language_code).id
      name = names.detect{|n| n.language_id==language_id}
      names.delete(name) if !name.nil?
      name
    end
  end
end