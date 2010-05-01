class CachedCategoryCount < ActiveRecord::Base
  belongs_to :category
  
  def self.cached_count(category_id)
    CachedCategoryCount.find(:first, :conditions => {:category_id => category_id})
  end
  
  def self.updated_count(category_id, force_update = false)
    cached_count = self.cached_count(category_id)
    latest_update = FeatureObjectType.latest_update
    if cached_count.nil?
      cached_count = CachedCategoryCount.new(:category_id => category_id, :cache_updated_at => latest_update)
    else
      if force_update || cached_count.cache_updated_at < latest_update
        cached_count.cache_updated_at = latest_update
      else
        return cached_count
      end
    end
    cached_count.count = CumulativeCategoryFeatureAssociation.count(:conditions => {:category_id => category_id})
    cached_count.save
    return cached_count
  end
end


# == Schema Info
# Schema version: 20100428184445
#
# Table name: cached_category_counts
#
#  id               :integer         not null, primary key
#  category_id      :integer         not null
#  count            :integer         not null
#  cache_updated_at :timestamp       not null
#  created_at       :timestamp
#  updated_at       :timestamp