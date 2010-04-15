# == Schema Information
#
# Table name: cached_feature_relation_categories
#
#  id                  :integer         not null, primary key
#  feature_id          :integer
#  related_feature_id  :integer
#  category_id         :integer
#  role                :string(255)
#  perspective_id      :integer
#  created_at          :timestamp
#  updated_at          :timestamp
#

class CachedFeatureRelationCategory < ActiveRecord::Base
  belongs_to :feature
  belongs_to :related_feature, :class_name => "Feature"
  belongs_to :category
  belongs_to :perspective
end