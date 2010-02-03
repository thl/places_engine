class AddInfoSourceIdToFeatureGeoCode < ActiveRecord::Migration
  def self.up
    add_column :feature_geo_codes, :info_source_id, :integer, :default => nil
  end

  def self.down
    remove_column :feature_geo_codes, :info_source_id
  end
end
