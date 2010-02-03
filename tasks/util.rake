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
  
end
