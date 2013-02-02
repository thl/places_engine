# require 'config/environment'

namespace :cache do
  namespace :tree do
    desc 'Run to preheat cache for all nodes of the browse tree.'
    task :heat do
      fid = ENV['FID']
      perspective_code = ENV['PERSPECTIVE']
      view_code = ENV['VIEW']
      start = Time.now
      puts "#{start}: Creating cache files#{" for #{fid}" if !fid.blank?}..."
      TreeCache.reheat(fid, perspective_code, view_code) # nil specifies that all nodes should be re-created. Otherwise, this is the id for the node whose descendants and self should be re-generated
      stop = Time.now
      puts "#{stop}: Finished successfully. Time lapsed: #{stop - start}"
    end
  end
  namespace :db do
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
    namespace :feature_relation_category do
      desc 'Run to empty and repopulate cached feature relation categories for the first time.'
      task :create do
        puts 'Clearing up caching...'
        CategoryCachingUtils.clear_feature_relation_category_table
        puts 'Creating cache...'
        CategoryCachingUtils.create_feature_relation_categories
        puts 'Finished successfully.'
      end
    end
  end
  namespace :view do
      desc "Deletes view cache"
      task(:clear) { |t| Dir.chdir('public') { ['categories', 'features'].each{ |folder| `rm -rf #{folder}` } } }
  end
end