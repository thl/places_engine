require 'kmaps_engine/flare_utils'

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
    
    desc "Reindexes features updated after last full reindex."
    task :reindex_stale_since_all => :environment do
      KmapsEngine::FlareUtils.reindex_stale_since_all([Altitude, CategoryFeature, Contestation, Shape])
    end
    
    desc "Create solr documents in filesystem. rake places_engine:flare:fs_reindex_all [FROM=fid] [TO=fid] [FIDS=fid1,fid2,...] [DAYLIGHT=daylight] [LOG_LEVEL=0..5]"
    task fs_reindex_all: :environment do
      pathname = Pathname.new(PlacesIntegration::Feature.get_url)
      KmapsEngine::FlareUtils.new("log/reindexing_#{Rails.env}.log", ENV['LOG_LEVEL']).reindex_all(from: ENV['FROM'], to: ENV['TO'], fids: ENV['FIDS'], daylight: ENV['DAYLIGHT']) do |f|
        URI.open(pathname.join('solr', "#{f.fid}.json").to_s, read_timeout: 360)
      end
    end
  end
end