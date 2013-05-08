module PlacesEngine
  module Extension
    module CachedCategoryCountExtension
      extend ActiveSupport::Concern

      included do
      end

      module ClassMethods
        # this takes into account count_with_shapes
        def updated_count(category_id, force_update = false)
          cached_count = CachedCategoryCount.where(:category_id => category_id).first
          latest_update = CategoryFeature.latest_update
          non_existent = false
          if cached_count.nil?
            # make sure category actually exists!
            category = Category.find(category_id)
            non_existent = true if category.nil?
            cached_count = CachedCategoryCount.new(:category_id => category_id)
          else
            return cached_count if !force_update && cached_count.cache_updated_at >= latest_update
          end
          cached_count.cache_updated_at = latest_update
          if non_existent
            cached_count.count = 0
            cached_count.count_with_shapes = 0
          else
            cached_count.count = CumulativeCategoryFeatureAssociation.where(:category_id => category_id).count
            cached_count.count_with_shapes = CumulativeCategoryFeatureAssociation.where(['category_id = ? AND geometry IS NOT NULL', category_id]).joins(:feature => :shapes).select('DISTINCT cumulative_category_feature_associations.id').count
            cached_count.save
          end
          return cached_count
        end
      end
    end
  end
end