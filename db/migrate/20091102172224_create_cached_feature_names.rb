class CreateCachedFeatureNames < ActiveRecord::Migration
  def self.up
    create_table :cached_feature_names do |t|
      t.integer :feature_id, :null => false
      t.integer :view_id, :null => false
      t.integer :feature_name_id

      t.timestamps
    end
    add_index :cached_feature_names, [:feature_id, :view_id], :unique => true
    CachedFeatureName.reset_column_information
    Feature.update_cached_feature_names
  end

  def self.down
    drop_table :cached_feature_names
  end
end
