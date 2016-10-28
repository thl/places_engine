class FeatureObjectType < CategoryFeature
  
  #
  #
  # Associations
  #
  #
  belongs_to :perspective
  has_many :imports, :as => 'item', :dependent => :destroy
  
  after_save do |record|
    record.feature.update_object_type_positions if !record.skip_update
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
