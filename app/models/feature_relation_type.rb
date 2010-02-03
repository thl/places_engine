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

class FeatureRelationType < SimpleProp
  
  #
  #
  # Associations
  #
  #
  has_many :relations, :class_name=>'FeatureRelation', :foreign_key=>:feature_relation_type_id
  
  #
  #
  # Validation
  #
  #
  
end
