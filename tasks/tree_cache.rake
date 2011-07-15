require 'config/environment'

namespace :cache do
  namespace :tree do
    desc 'Run to preheat cache for all nodes of the browse tree.'
    task :heat do
      puts 'Creating cache files...'
      TreeCache.reheat(0) # 0 specifies that all nodes should be re-created. Otherwise, this is the id for the node whose descendants and self should be re-generated
      puts 'Finished successfully.'
    end
  end
end