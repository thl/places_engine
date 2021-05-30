class CategoryFeatureSweeper < ActionController::Caching::Sweeper
  observe CategoryFeature
  
  def after_save(record)
    expire_cache(record)
  end
  
  def after_touch(record)
    expire_cache(record)
  end
  
  def after_destroy(record)
    expire_cache(record)
  end
  
  def expire_cache(record)
    feature = record.feature
    FeatureRelationSweeper.instance.expire_cache(feature) if !feature.nil?
  end
end