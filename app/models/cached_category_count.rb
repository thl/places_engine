class CachedCategoryCount < ActiveRecord::Base
  belongs_to :category
  
  def self.updated_count(category_id, force_update = false)
    cached_count = CachedCategoryCount.find(:first, :conditions => {:category_id => category_id})
    latest_update = CategoryFeature.latest_update
    non_existent = false
    if cached_count.nil?
      # make sure category actually exists!
      category = Category.find(category_id)
      non_existent = true if category.nil?
      cached_count = CachedCategoryCount.new(:category_id => category_id)
    else
      return cached_count if !force_update && cached_count.cache_updated_at >= latest_update
    end
    cached_count.cache_updated_at = latest_update
    if non_existent
      cached_count.count = 0
      cached_count.count_with_shapes = 0
    else
      cached_count.count = CumulativeCategoryFeatureAssociation.count(:conditions => {:category_id => category_id})
      cached_count.count_with_shapes = CumulativeCategoryFeatureAssociation.count('id', :distinct => true, :conditions => ['category_id = ? AND geometry IS NOT NULL', category_id], :joins => {:feature => :shapes})
      cached_count.save
    end
    return cached_count
  end
end

# == Schema Info
# Schema version: 20110923232332
#
# Table name: cached_category_counts
#
#  id                :integer         not null, primary key
#  category_id       :integer         not null
#  count             :integer         not null
#  count_with_shapes :integer         not null
#  cache_updated_at  :timestamp       not null
#  created_at        :timestamp
#  updated_at        :timestamp