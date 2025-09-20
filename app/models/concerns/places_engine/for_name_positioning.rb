module PlacesEngine
  module ForNamePositioning
    def figure_out_name_by_country(names)
      # order matters, that is why I am using ancestor_ids instead of ancestors
      ordered_ancestors = self.ancestor_ids.blank? ? [] : self.ancestor_ids.split('.').delete_if{|id| id.blank?}.collect(&:to_i)
      id = ([self.fid] + ordered_ancestors).detect{|id| Feature::LANG_CODES_BY_FEATURE_IDS[id]}
      return nil if id.nil?
      Feature::HelperMethods.figure_out_name_by_language_code(names, Feature::LANG_CODES_BY_FEATURE_IDS[id])
    end
    
    def calculate_name_positions(names_param = self.names.roots.order('feature_names.created_at'), position = 1)
      names = names_param.to_a
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
          name = Feature::HelperMethods.figure_out_name_by_language_code(names, 'eng')
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
      sorted_names.keys.sort.inject(sorted_names.dup) {|names, i| names.merge(calculate_name_positions(sorted_names[i].children.order('feature_names.created_at'), names.keys.max + 1)) }
    end

    extend ActiveSupport::Concern

    included do
      LANG_CODES_BY_FIDS = {5244 => 'urd', 427 => 'dzo', 426 => 'nep', 425 => 'hin', 2 => 'bod', 431 => 'bod', 432 => 'bod', 428 => 'bod', 430 => 'bod', 1 => 'zho'}
      LANG_CODES_BY_FEATURE_IDS = {}
      LANG_CODES_BY_FIDS.each_key{|fid| LANG_CODES_BY_FEATURE_IDS[Feature.get_by_fid(fid).id] = LANG_CODES_BY_FIDS[fid] }
    end

    module ClassMethods
    end
  end
end