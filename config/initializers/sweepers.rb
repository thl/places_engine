#sweeper_folder = File.join('..', '..', 'app', 'sweepers')
#require_relative File.join(sweeper_folder, 'cached_category_count_sweeper')
#require_relative File.join(sweeper_folder, 'location_sweeper')
Rails.application.config.to_prepare do
  observers = [CachedCategoryCountSweeper, CategoryFeatureSweeper, LocationSweeper]
  Rails.application.config.active_record.observers ||= []
  Rails.application.config.active_record.observers += observers
  observers.each { |o| o.instance }
end