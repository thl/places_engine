class Topic < SubjectsIntegration::Feature
  self.element_name = 'feature'
    
  def features(**options)
    joins = options[:cumulative] ? :cumulative_category_feature_associations : :category_features
    Feature.where("#{joins}.category_id" => self.id).joins(joins)
  end
    
  def feature_count(**options)
    association = options[:cumulative] || false ? CumulativeCategoryFeatureAssociation : CategoryFeature
    association.where(:category_id => self.id).count
  end
end