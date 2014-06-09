class LocationSweeper < ActionController::Caching::Sweeper
  observe Shape, Altitude
  FORMATS = ['xml', 'json']
  
  def after_save(record)
    expire_cache(record)
  end
  
  def after_destroy(record)
    expire_cache(record)
  end
  
  def expire_cache(record)
    options = {:only_path => true, :feature_id => record.feature.fid}
    FORMATS.each do |format|
      options[:format] = format
      expire_page feature_locations_url(options)
    end
  end
end