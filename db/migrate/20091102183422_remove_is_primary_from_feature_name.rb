class RemoveIsPrimaryFromFeatureName < ActiveRecord::Migration
  def self.up
    remove_column :feature_names, :is_primary
  end

  def self.down
    add_column :feature_names, :is_primary, :integer
  end
end
