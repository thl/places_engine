class CumulativeCategoryFeatureAssociation < ActiveRecord::Base
  belongs_to :feature
  belongs_to :category
end

# == Schema Info
# Schema version: 20100609203100
#
# Table name: cumulative_category_feature_associations
#
#  id          :integer         not null, primary key
#  category_id :integer         not null
#  feature_id  :integer         not null
#  created_at  :timestamp
#  updated_at  :timestamp