class LocationSweeper < ActionController::Caching::Sweeper
  include InterfaceUtils::SweeperExtensions
  include Rails.application.routes.url_helpers
  include ActionController::Caching::Pages
  
  observe Shape, Altitude
  FORMATS = ['xml', 'json']
  
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
    options = {:only_path => true, :feature_id => record.feature.fid}
    FORMATS.each do |format|
      options[:format] = format
      expire_full_path_page feature_locations_url(options)
    end
  end
end