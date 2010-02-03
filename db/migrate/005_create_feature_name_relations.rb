class CreateFeatureNameRelations < ActiveRecord::Migration
  def self.up
    create_table :feature_name_relations, :force=>true do |t|
      
      # The source/primary object (parent?)
      t.column :child_node_id, :integer, :null=>false
      
      # The target/secondary object (child?)
      t.column :parent_node_id, :integer, :null=>false
      
      t.string :ancestor_ids
      
      # I think this is a mistake. Maybe it got left in here by copying from the create_feature_relations migration?
      ## mwm4n - yes, you're right...
      #t.column :feature_relation_type_id, :integer, :null=>false
      
      t.column :is_phonetic, :boolean, :default=>false
      t.column :is_orthographic, :boolean, :default=>false
      t.column :is_translation, :boolean, :default=>false
      t.column :is_alt_spelling, :boolean, :default=>false
      
      t.column :phonetic_system_id, :integer
      t.column :orthographic_system_id, :integer
      t.column :alt_spelling_system_id, :integer
      
			t.timestamps
    end
    
    add_index :feature_name_relations, :child_node_id
    add_index :feature_name_relations, :parent_node_id
    
  end

  def self.down
    remove_index :feature_name_relations, :child_node_id
    remove_index :feature_name_relations, :parent_node_id
    drop_table :feature_name_relations
  end
end