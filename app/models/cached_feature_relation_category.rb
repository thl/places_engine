class CachedFeatureRelationCategory < ActiveRecord::Base
  belongs_to :feature
  belongs_to :related_feature, :class_name => "Feature"
  belongs_to :category
  belongs_to :perspective
end

# == Schema Info
# Schema version: 20100428184445
#
# Table name: cached_feature_relation_categories
#
#  id                 :integer         not null, primary key
#  category_id        :integer
#  feature_id         :integer
#  perspective_id     :integer
#  related_feature_id :integer
#  role               :string(255)
#  created_at         :timestamp
#  updated_at         :timestamp