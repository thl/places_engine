namespace :position do
  namespace :feature do
    desc 'Fill out position for features'
    task :reset do
      Feature.reset_positions
    end
  end
  
  namespace :name do
    desc 'Fill out position for feature names'
    task :reset do
      Feature.reset_name_positions
    end
    
    desc 'Update name positions for feature names'
    task :update do
      Feature.update_name_positions
    end
    
    desc 'Delete all names with no clearly assigned position'
    task :cleanup do
      FeatureName.destroy_all(['position = ?', 0])
    end
    
    desc 'Restructure chinese names to make simplified Chinese under traditional Chinese'
    task :restructure_chinese do
      puts "Changed the following features: #{Feature.restructure_chinese_names.collect(&:fid).sort.join(', ')}."
    end    
  end
end
