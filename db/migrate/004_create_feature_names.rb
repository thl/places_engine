class CreateFeatureNames < ActiveRecord::Migration
  def self.up
    create_table :feature_names, :force=>true do |t|
      
      t.column :feature_id, :integer, :null => false
      
      t.column :is_public, :boolean, :default=>false
      
      t.column :is_primary, :boolean
      
      t.column :name, :string, :null=>false
      t.column :feature_name_type_id, :integer
      
      t.string :ancestor_ids
      
      # The ordering number in reference to the feature
      t.column :position, :integer, :default=>0
      
      # Etymology will probably need to change once the THDL dictionary is complete
      t.column :etymology, :string
      
      t.column :writing_system_id, :integer
      # This is the language of the name (geogname)
      t.column :language_id, :integer, :null=>false
      
			t.timestamps
    end
    
    add_index :feature_names, :feature_id
    add_index :feature_names, :name
    add_index :feature_names, :is_public
    add_index :feature_names, :ancestor_ids
    
  end

  def self.down
    remove_index :feature_names, :feature_id
    remove_index :feature_names, :name
    remove_index :feature_names, :is_public
    remove_index :feature_names, :ancestor_ids
    drop_table :feature_names
  end
end