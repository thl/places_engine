# == Schema Information
# Schema version: 20091102185045
#
# Table name: feature_object_types
#
#  id             :integer         not null, primary key
#  feature_id     :integer         not null
#  object_type_id :integer         not null
#  perspective_id :integer
#  created_at     :timestamp
#  updated_at     :timestamp
#  position       :integer         :default => 0
#

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