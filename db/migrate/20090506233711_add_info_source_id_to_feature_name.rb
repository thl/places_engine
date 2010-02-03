class AddInfoSourceIdToFeatureName < ActiveRecord::Migration
  def self.up
    add_column :feature_names, :info_source_id, :integer, :default => nil
  end

  def self.down
    remove_column :feature_names, :info_source_id
  end
end
