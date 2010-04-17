module CategoryCachingUtils
  def self.clear_caching_tables
    FeatureObjectType.connection.execute('TRUNCATE TABLE cached_category_counts')
    CumulativeCategoryFeatureAssociation.connection.execute('TRUNCATE TABLE cumulative_category_feature_associations')
  end
  
  def self.create_cumulative_feature_associations
    FeatureObjectType.find(:all, :select =>'DISTINCT(category_id)', :order => 'category_id').collect(&:category).each do |category|
      feature_ids = FeatureObjectType.find(:all, :conditions => {:category_id => category.id}, :order => 'feature_id').collect(&:feature_id)
      ([category] + category.ancestors).each {|c| feature_ids.each {|feature_id| CumulativeCategoryFeatureAssociation.create(:category => c, :feature_id => feature_id) if (c.id==category.id || c.cumulative?) && CumulativeCategoryFeatureAssociation.find(:first, :conditions => {:category_id => c.id, :feature_id => feature_id}).nil?}}
    end
  end
end