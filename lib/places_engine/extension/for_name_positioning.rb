module PlacesEngine
  module Extension
    module ForNamePositioning
      def figure_out_name_by_country(names)
        # order matters, that is why I am using ancestor_ids instead of ancestors
        ordered_ancestors = self.ancestor_ids.blank? ? [] : self.ancestor_ids.split('.').delete_if{|id| id.blank?}.collect(&:to_i)
        id = ([self.fid] + ordered_ancestors).detect{|id| Feature::LANG_CODES_BY_FEATURE_IDS[id]}
        return nil if id.nil?
        HelperMethods.figure_out_name_by_language_code(names, Feature::LANG_CODES_BY_FEATURE_IDS[id])
      end

      extend ActiveSupport::Concern

      included do
        LANG_CODES_BY_FIDS = {5244 => 'urd', 427 => 'dzo', 426 => 'nep', 425 => 'hin', 2 => 'tib', 431 => 'tib', 432 => 'tib', 428 => 'tib', 430 => 'tib', 1 => 'chi'}
        LANG_CODES_BY_FEATURE_IDS = {}
        LANG_CODES_BY_FIDS.each_key{|fid| LANG_CODES_BY_FEATURE_IDS[Feature.find_by_fid(fid).id] = LANG_CODES_BY_FIDS[fid] }
      end

      module ClassMethods
      end
    end
  end
end