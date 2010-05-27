class FeatureObjectType < CategoryFeature
  
  #
  #
  # Associations
  #
  #
  belongs_to :perspective
  
  def after_save
    super
    self.feature.update_object_type_positions
  end
end

# == Schema Info
# Schema version: 20100526225546
#
# Table name: category_features
#
#  id             :integer         not null, primary key
#  category_id    :integer         not null
#  feature_id     :integer         not null
#  perspective_id :integer
#  numeric_value  :integer
#  position       :integer         not null, default(0)
#  string_value   :string(255)
#  type           :string(255)
#  created_at     :timestamp
#  updated_at     :timestamp