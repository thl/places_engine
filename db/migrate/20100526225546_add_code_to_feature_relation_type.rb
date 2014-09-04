class AddCodeToFeatureRelationType < ActiveRecord::Migration
  def self.up
    change_column :feature_relations, :feature_relation_type_id, :integer, :null => false
    change_column :feature_relations, :perspective_id, :integer, :null => false
    change_column :feature_relation_types, :label, :string, :null => false
    add_column :feature_relation_types, :code, :string
    FeatureRelationType.reset_column_information
    FeatureRelationType.all.each { |type| type.update_attribute(:code, (type.asymmetric_label || type.label).downcase.squish.gsub( /\s/, '.' )) }
    change_column :feature_relation_types, :code, :string, :null => false    
  end

  def self.down
    change_column :feature_relations, :feature_relation_type_id, :integer, :null => true
    change_column :feature_relations, :perspective_id, :integer, :null => true
    change_column :feature_relation_types, :label, :string, :null => true
    remove_column :feature_relation_types, :code
  end
end