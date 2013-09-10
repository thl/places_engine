# require 'config/environment'
require 'places_engine/category_caching_utils'

namespace :cache do
  namespace :db do
    namespace :category do
      desc 'Run to create to empty and re-populate cumulative category association for the first time.'
      task :clear do
        puts 'Clearing up caching...'
        PlacesEngine::CategoryCachingUtils.clear_caching_tables
        PlacesEngine::CategoryCachingUtils.create_cumulative_feature_associations
        puts 'Finished successfully.'
      end
    end
    namespace :feature_relation_category do
      desc 'Run to empty and repopulate cached feature relation categories for the first time.'
      task :create do
        puts 'Clearing up caching...'
        PlacesEngine::CategoryCachingUtils.clear_feature_relation_category_table
        puts 'Creating cache...'
        PlacesEngine::CategoryCachingUtils.create_feature_relation_categories
        puts 'Finished successfully.'
      end
    end
  end
  namespace :view do
      desc "Deletes view cache"
      task(:clear) { |t| Dir.chdir('public') { ['categories', 'features'].each{ |folder| `rm -rf #{folder}` } } }
  end
end