module CategoryCachingUtils
  def self.clear_caching_tables
    FeatureObjectType.connection.execute('TRUNCATE TABLE cached_category_counts')
    CumulativeCategoryFeatureAssociation.connection.execute('TRUNCATE TABLE cumulative_category_feature_associations')
  end
  
  def self.create_cumulative_feature_associations
    FeatureObjectType.find(:all, :select =>'DISTINCT(object_type_id)', :order => 'object_type_id').collect(&:object_type).each do |category|
      feature_ids = FeatureObjectType.find(:all, :conditions => {:object_type_id => category.id}, :order => 'feature_id').collect(&:feature_id)
      ([category] + category.ancestors).each {|c| feature_ids.each {|feature_id| CumulativeCategoryFeatureAssociation.create(:category => c, :feature_id => feature_id) if (c.id==category.id || c.cumulative?) && CumulativeCategoryFeatureAssociation.find(:first, :conditions => {:category_id => c.id, :feature_id => feature_id}).nil?}}
    end
  end
  
  def self.clear_feature_relation_category_table
    CachedFeatureRelationCategory.connection.execute('TRUNCATE TABLE cached_feature_relation_categories')
  end
  
  def self.create_feature_relation_categories
    Feature.find(:all).each{|f| f.update_cached_feature_relation_categories}
  end
end