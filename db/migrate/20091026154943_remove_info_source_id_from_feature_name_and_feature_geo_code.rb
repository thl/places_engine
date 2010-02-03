class RemoveInfoSourceIdFromFeatureNameAndFeatureGeoCode < ActiveRecord::Migration
  def self.up
    remove_column :feature_names, :info_source_id
    remove_column :feature_geo_codes, :info_source_id
  end

  def self.down
    add_column :feature_names, :info_source_id, :integer
    add_column :feature_geo_codes, :info_source_id, :integer
  end
end
