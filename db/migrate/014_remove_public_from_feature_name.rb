class RemovePublicFromFeatureName < ActiveRecord::Migration
  def self.up
    remove_column :feature_names, :is_public
  end

  def self.down
    add_column :feature_names, :is_public, :boolean, :default => false
  end
end
