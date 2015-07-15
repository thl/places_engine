class CachedCategoryCountSweeper < ActiveRecord::Observer
  include InterfaceUtils::Extensions::Sweeper
  
  observe CachedCategoryCount
  
  def after_save(cf)
    expire_cache(cf.category_id)
  end
  
  def after_destroy(cf)
    expire_cache(cf.category_id)
  end
  
  def expire_cache(c)
    expire_full_path_page("/categories/#{c}/counts.xml") if !c.nil?
  end
end