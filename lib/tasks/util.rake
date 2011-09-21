namespace :util do
  
  desc 'Synchronizes all of the ancestor/descendant data within the hiearchical models'
  task :reset_ancestor_ids=>:environment do
    [Feature,FeatureRelation,FeatureName,FeatureNameRelation].each do |c|
      puts ''
      puts "Reseting #{c.to_s.titleize} ancestor ids"
      #c.update_hierarchy
      c.reset_ancestor_ids
    end
  end
  
  desc 'Synchronizes all of the ancestor data for features'
  task :reset_feature_ancestor_ids=>:environment do
    puts ''
    puts "Reseting feature ancestor ids"
    Feature.reset_ancestor_ids
  end  
end
