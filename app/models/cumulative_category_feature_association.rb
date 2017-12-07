class CumulativeCategoryFeatureAssociation < ActiveRecord::Base
  #attr_accessible :category_id, :feature_id, :skip_update
  
  attr_accessor :skip_update
  
  belongs_to :feature
  # belongs_to :category
  
  after_save { |record| CachedCategoryCount.updated_count(record.category_id) if !record.skip_update }
end
# == Schema Information
#
# Table name: cumulative_category_feature_associations
#
#  id          :integer          not null, primary key
#  feature_id  :integer          not null
#  category_id :integer          not null
#  created_at  :datetime
#  updated_at  :datetime
#

#  updated_at  :timestamp
