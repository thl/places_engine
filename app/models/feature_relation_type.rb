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


# == Schema Info
# Schema version: 20100428184445
#
# Table name: simple_props
#
#  id          :integer         not null, primary key
#  code        :string(255)
#  description :text
#  name        :string(255)
#  notes       :text
#  type        :string(255)
#  created_at  :timestamp
#  updated_at  :timestamp