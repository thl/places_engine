# == Schema Information
#
# Table name: cached_feature_relation_categories
#
#  id                       :integer          not null, primary key
#  feature_id               :integer
#  related_feature_id       :integer
#  category_id              :integer
#  perspective_id           :integer
#  created_at               :datetime
#  updated_at               :datetime
#  feature_relation_type_id :integer
#  feature_is_parent        :boolean
#

class CachedFeatureRelationCategory < ActiveRecord::Base
  attr_accessible :feature_id, :related_feature_id, :category_id, :feature_relation_type_id, :feature_is_parent,
    :perspective_id
  belongs_to :feature
  belongs_to :related_feature, :class_name => "Feature"
  # belongs_to :category
  belongs_to :feature_relation_type
  belongs_to :perspective
end