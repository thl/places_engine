class Topic < Category
  headers['Host'] = TopicalMapResource.headers['Host'] if !TopicalMapResource.headers['Host'].blank?
  self.element_name = 'category'
    
  def features(options = {})
    joins = options[:cumulative] ? :cumulative_category_feature_associations : :category_features
    Feature.find(:all, :conditions => {"#{joins}.category_id" => self.id}, :joins => joins)
  end
    
  def feature_count(options = {})
    association = options[:cumulative] || false ? CumulativeCategoryFeatureAssociation : CategoryFeature
    association.count(:conditions => {:category_id => self.id})
  end
end