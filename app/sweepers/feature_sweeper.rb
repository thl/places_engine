class FeatureSweeper < ActionController::Caching::Sweeper
  observe Feature
  
  def after_save(feature)
    expire_cache(feature)
  end
  
  def after_destroy(feature)
    expire_cache(feature)
  end
  
  def expire_cache(feature)
    expire_page feature_url(feature.fid, :skip_relative_url_root => true, :only_path => true, :format => 'xml')
  end
end