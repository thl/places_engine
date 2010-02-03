class CreateFeatureObjectTypes < ActiveRecord::Migration
  def self.up
    create_table :feature_object_types, :force=>true do |t|
      t.integer :feature_id, :null=>false
      t.integer :object_type_id, :null=>false
      t.integer :perspective_id
      t.timestamps
    end
    
    add_index :feature_object_types, :feature_id
    add_index :feature_object_types, :object_type_id
    add_index :feature_object_types, :perspective_id
    
  end

  def self.down
    remove_index :feature_object_types, :feature_id
    remove_index :feature_object_types, :object_type_id
    remove_index :feature_object_types, :perspective_id
    drop_table :feature_object_types
  end
end