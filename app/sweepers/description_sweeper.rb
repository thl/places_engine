class DescriptionSweeper < ActionController::Caching::Sweeper
  observe Description
  FORMATS = ['xml', 'json']
  
  def after_save(record)
    expire_cache(record)
  end
  
  def after_destroy(record)
    expire_cache(record)
  end
  
  def expire_cache(description)
    feature = description.feature
    options = {:skip_relative_url_root => true, :only_path => true}
    FORMATS.each do |format|
      options[:format] = format
      expire_page feature_description_url(feature.fid, description, options)
      expire_page feature_descriptions_url(feature.fid, options)
      expire_page feature_url(feature.fid, options)
    end
  end
end