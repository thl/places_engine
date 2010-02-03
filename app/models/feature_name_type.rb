# == Schema Information
# Schema version: 20091102185045
#
# Table name: simple_props
#
#  id          :integer         not null, primary key
#  name        :string(255)
#  code        :string(255)
#  description :text
#  notes       :text
#  type        :string(255)
#  created_at  :timestamp
#  updated_at  :timestamp
#

class FeatureNameType < SimpleProp
  
  # Link up the FeatureNames associated with this type
  # by using the FeatureName.feature_name_type_id value
  has_many :feature_names, :class_name=>'FeatureName', :source=>:feature_name_type_id
  
  #
  #
  # Validation
  #
  #
  
end
