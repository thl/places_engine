require 'config/environment'
namespace :db do
  namespace :cache do
    namespace :category do
      desc 'Run to create to empty and re-populate cumulative category association for the first time.'
      task :clear do
        puts 'Clearing up caching...'
        CategoryCachingUtils.clear_caching_tables
        CategoryCachingUtils.create_cumulative_feature_associations
        puts 'Finished successfully.'
      end
    end
    namespace :name do
      desc 'Run to update names by view.'
      task :update do
        puts 'Updating names by view...'
        Feature.update_cached_feature_names
        puts 'Finished successfully.'
      end
    end
  end
end