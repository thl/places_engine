namespace :places_engine do
  namespace :flare do
    desc "Reindex all features with subjects in solr. rake places_engine:flare:reindex_all_with_subjects"
    task :reindex_all_with_subjects => :environment do
      features = CategoryFeature.where(:type => nil).select('feature_id').distinct.order('feature_id').collect(&:feature).compact
      features.each do |f|
        if f.index
          puts "#{Time.now}: Reindexed #{f.fid}."
        else
          puts "#{Time.now}: #{f.fid} failed."
        end
      end
    end
  end
end