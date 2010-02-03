# == Schema Information
# Schema version: 20091102185045
#
# Table name: cumulative_category_feature_associations
#
#  id          :integer         not null, primary key
#  feature_id  :integer         not null
#  category_id :integer         not null
#  created_at  :timestamp
#  updated_at  :timestamp
#

class CumulativeCategoryFeatureAssociation < ActiveRecord::Base
  belongs_to :feature
  belongs_to :category
end
