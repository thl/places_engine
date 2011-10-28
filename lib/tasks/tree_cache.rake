require 'config/environment'

namespace :cache do
  namespace :tree do
    desc 'Run to preheat cache for all nodes of the browse tree.'
    task :heat do
      fid = ENV['FID']
      if fid.blank?
        puts 'Creating cache files...'
      else
        puts "Creating cache files for #{fid}..."
      end
      TreeCache.reheat(fid) # 0 specifies that all nodes should be re-created. Otherwise, this is the id for the node whose descendants and self should be re-generated
      puts 'Finished successfully.'
    end
  end
end