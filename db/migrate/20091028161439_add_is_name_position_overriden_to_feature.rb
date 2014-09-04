class AddIsNamePositionOverridenToFeature < ActiveRecord::Migration
  def self.up
    add_column :features, :is_name_position_overriden, :boolean, :null => false, :default => false
    FeatureName.reset_column_information
    FeatureName.all.reject{ |n| n.feature }.each{ |n| n.destroy }
    FeatureName.where(:position => 0).order('created_at').each { |n| n.feature.update_name_positions }
    Feature.order('fid').each { |f| f.update_is_name_position_overriden }
  end

  def self.down
    remove_column :feature_names, :is_name_position_overriden
  end
end
