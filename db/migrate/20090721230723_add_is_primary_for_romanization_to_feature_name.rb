class AddIsPrimaryForRomanizationToFeatureName < ActiveRecord::Migration
  def self.up
    add_column :feature_names, :is_primary_for_romanization, :boolean, :default=>false
    FeatureName.reset_column_information
    FeatureName.update_all( "is_primary_for_romanization = false" )
  end

  def self.down
    remove_column :feature_names, :is_primary_for_romanization
  end
end
