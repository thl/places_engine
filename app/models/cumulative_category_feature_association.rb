class CumulativeCategoryFeatureAssociation < ActiveRecord::Base
  attr_accessor :skip_update
  
  belongs_to :feature
  belongs_to :category
  
  after_save { |record| CachedCategoryCount.updated_count(record.category_id) if !record.skip_update }
end

# == Schema Info
# Schema version: 20100623234636
#
# Table name: cumulative_category_feature_associations
#
#  id          :integer         not null, primary key
#  category_id :integer         not null
#  feature_id  :integer         not null
#  created_at  :timestamp
#  updated_at  :timestamp