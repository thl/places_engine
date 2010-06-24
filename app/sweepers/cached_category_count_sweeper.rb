class CachedCategoryCountSweeper < ActiveRecord::Observer
  observe CachedCategoryCount
  
  def after_save(cf)
    expire_cache(cf.category_id)
  end
  
  def after_destroy(cf)
    expire_cache(cf.category_id)
  end
  
  def expire_cache(c)
    ApplicationController.expire_page("/categories/#{c}/counts.xml") if !c.nil?
  end
end