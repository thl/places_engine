module PlacesEngine
  class Engine < ::Rails::Engine
    initializer :assets do |config|
      Rails.application.config.assets.precompile.concat(['places_engine/admin.js', 'places_engine/public.js',
        'places_engine/top.js', 'places_engine/iframe.js', 'places_engine/jquery.ajax.sortable.js',
        'places_engine/admin.css', 'places_engine/public.css', 'places_engine/xml-books.css'])
    end
    
    initializer :sweepers do |config|
      sweeper_folder = File.join(File.dirname(__FILE__), '..', '..', 'app', 'sweepers')
      require File.join(sweeper_folder, 'cached_category_count_sweeper')
      require File.join(sweeper_folder, 'feature_sweeper')
      require File.join(sweeper_folder, 'description_sweeper')
      Rails.application.config.active_record.observers = :cached_category_count_sweeper
    end    
  end
end
