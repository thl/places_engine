module PlacesEngine
  module CategoryCachingUtils
    def self.clear_caching_tables
      CachedCategoryCount.connection.execute('TRUNCATE TABLE cached_category_counts')
      CumulativeCategoryFeatureAssociation.connection.execute('TRUNCATE TABLE cumulative_category_feature_associations')
    end

    def self.create_cumulative_feature_associations
      categories = CategoryFeature.select('DISTINCT(category_id)').order('category_id').collect(&:category)
      puts "Processing #{categories.size} topics..."
      categories.each do |category|
        next if category.nil?
        puts "Processing topic #{category.id}"
        feature_ids = CategoryFeature.where(:category_id => category.id).order('feature_id').collect(&:feature_id)
        ancestors = category.ancestors
        ([category] + ancestors).each do |c|
          # c.id==category.id || c.cumulative? Got rid of this condition while I figure out how to deal with this
          feature_ids.each { |feature_id| CumulativeCategoryFeatureAssociation.create(:category_id => c.id, :feature_id => feature_id, :skip_update => true) if CumulativeCategoryFeatureAssociation.find_by(category_id: c.id, feature_id: feature_id).nil? }
          CachedCategoryCount.updated_count(c.id, true)
        end
      end
    end

    def self.clear_feature_relation_category_table
      CachedFeatureRelationCategory.connection.execute('TRUNCATE TABLE cached_feature_relation_categories')
    end

    def self.create_feature_relation_categories
      Feature.all.order(:fid).each do |f|
        puts "Processing #{f.fid}"
        f.update_cached_feature_relation_categories
      end
    end
  end
end