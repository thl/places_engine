class AddIsHierarchicalToFeatureRelationType < ActiveRecord::Migration
  def self.up
    add_column :feature_relation_types, :is_hierarchical, :boolean, :null => false, :default => false
    FeatureRelationType.reset_column_information
    rt = FeatureRelationType.get_by_code('is.administered.by')
    rt.update_attribute(:is_hierarchical, true) if !rt.nil?
    rt = FeatureRelationType.get_by_code('is.part.of')
    rt.update_attribute(:is_hierarchical, true) if !rt.nil?
  end

  def self.down
    remove_column :feature_relation_types, :is_hierarchical
  end
end
