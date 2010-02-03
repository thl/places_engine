class CreateFeatureRelations < ActiveRecord::Migration
  
  def self.up
    
    # Features that are related - roles: partof, adjacent etc.
    create_table :feature_relations, :force=>true do |t|
        
        # The source/primary object (parent?)
        t.column :child_node_id, :integer, :null=>false
        
        # The target/secondary object (child?)
        t.column :parent_node_id, :integer, :null=>false
        
        t.string :ancestor_ids
				
				t.text :notes
				
				# If it's other than child/parent (intersects, adjacent)
				# The "alternative" type of relationship from the childs point of view
				t.string :role, :limit=>20
				
				t.column :perspective_id, :integer, :null=>false
				
				t.timestamps
    end
    
    add_index :feature_relations, :child_node_id
    add_index :feature_relations, :parent_node_id
    add_index :feature_relations, :ancestor_ids
    add_index :feature_relations, :perspective_id
    add_index :feature_relations, :role
    
  end
  
  def self.down
    remove_index :feature_relations, :child_node_id
    remove_index :feature_relations, :parent_node_id
    remove_index :feature_relations, :ancestor_ids
    remove_index :feature_relations, :perspective_id
    remove_index :feature_relations, :role
    drop_table :feature_relations
  end
end