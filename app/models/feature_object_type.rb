class FeatureObjectType < CategoryFeature
  
  #
  #
  # Associations
  #
  #
  belongs_to :perspective
  
  after_save do |record|
    record.feature.update_object_type_positions if !record.skip_update
  end
end

# == Schema Info
# Schema version: 20110629163847
#
# Table name: category_features
#
#  id             :integer         not null, primary key
#  category_id    :integer         not null
#  feature_id     :integer         not null
#  perspective_id :integer
#  numeric_value  :integer
#  position       :integer         not null, default(0)
#  show_parent    :boolean
#  show_root      :boolean         default(TRUE)
#  string_value   :string(255)
#  type           :string(255)
#  created_at     :timestamp
#  updated_at     :timestamp