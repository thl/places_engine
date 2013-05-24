# Before running this script, backup the database and know how to 
# restore it should something bad happen.
#
#------------------------------------------------------------------------------

class ConvertFeatureIds < ActiveRecord::Migration  
  def self.up
    # in order for this to work, the unique constraint on
    # features.pid has to be removed.
    
    remove_index :features, :name => "features_pid" rescue nil
    add_column :features, :old_pid, :string
    Feature.reset_column_information
    
    KmapsEngine::FeaturePidGenerator.current = 0
    feature_hash = Hash.new
    Feature.find(:all, :order => "created_at").each do |f|
      # get the next pid...
      f.old_pid = f.fid
      f.pid = KmapsEngine::FeaturePidGenerator.next
      unless f.save
        puts "** Failed to update Feature: #{f.id}"
      else
        puts "** Old PID: #{f.old_pid} changed to New PID: #{f.fid}"
        feature_hash[f.old_pid] = f.fid
      end
    end
    
    add_index :features, :pid, :name => "features_pid", :unique => true
    
    Shape.find(:all, :order => 'gid').each do |s| 
      new_pid = feature_hash[s.fid]
      if !new_pid.blank?
        s.fid = new_pid
        s.save
      end
    end
  end

  def self.down
    remove_index :features, :name => "features_pid" rescue nil
    feature_hash = Hash.new
    Feature.find(:all, :order => "created_at").each do |f|
      feature_hash[f.pid] = f.old_pid
      f.pid = f.old_pid
      f.save
    end
    remove_column :features, :old_pid
    add_index :features, :pid, :name => "features_pid", :unique => true
    Shape.find(:all, :order => 'gid').each do |s| 
      new_pid = feature_hash[s.fid]
      if !new_pid.blank?
        s.fid = new_pid
        s.save
      end
    end
  end
end
