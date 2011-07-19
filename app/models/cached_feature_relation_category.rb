class CachedFeatureRelationCategory < ActiveRecord::Base
  belongs_to :feature
  belongs_to :related_feature, :class_name => "Feature"
  belongs_to :category
  belongs_to :feature_relation_type
  belongs_to :perspective
end

# == Schema Info
# Schema version: 20110629163847
#
# Table name: cached_feature_relation_categories
#
#  id                       :integer         not null, primary key
#  category_id              :integer
#  feature_id               :integer
#  feature_relation_type_id :integer
#  perspective_id           :integer
#  related_feature_id       :integer
#  feature_is_parent        :boolean
#  created_at               :timestamp
#  updated_at               :timestamp