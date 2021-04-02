class FeatureObjectType < CategoryFeature
  BRANCH_ID=20
  
  
  after_save do |record|
    record.feature.update_object_type_positions if !record.skip_update
  end
  
  def citations
    Citation.where(citable_type: ['CategoryFeature', 'FeatureObjectType'], citable_id: self.id)
  end

  def time_units
    TimeUnit.where(dateable_type: ['CategoryFeature', 'FeatureObjectType'], dateable_id: self.id)
  end

  def notes
    Note.where(notable_type: ['CategoryFeature', 'FeatureObjectType'], notable_id: self.id)
  end
end
# == Schema Information
#
# Table name: category_features
#
#  id             :integer          not null, primary key
#  feature_id     :integer          not null
#  category_id    :integer          not null
#  perspective_id :integer
#  created_at     :datetime
#  updated_at     :datetime
#  position       :integer          default(0), not null
#  type           :string(255)
#  string_value   :string(255)
#  numeric_value  :integer
#  show_parent    :boolean          default(FALSE), not null
#  show_root      :boolean          default(TRUE), not null
#  label          :string(255)
#  prefix_label   :boolean          default(TRUE), not null
#

#  updated_at     :timestamp
