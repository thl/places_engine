class FeatureSweeper < ActionController::Caching::Sweeper
  observe Feature, FeatureRelation
  
  def after_save(record)
    expire_cache(record) if record.is_a?(Feature)
  end
  
  def after_destroy(record)
    expire_cache(record) if record.is_a?(Feature)
  end
  
  def expire_cache(feature)
    expire_page feature_url(feature.fid, :skip_relative_url_root => true, :only_path => true, :format => 'xml')
  end
  
  def after_commit(record)
    reheat_cache
  end
  
  def reheat_cache
    node_id = Rails.cache.read('tree_tmp') rescue nil
    unless node_id.nil?
      Rails.cache.delete('tree_tmp')
      TreeCache.reheat(node_id)
    end
  end
end