class CreateFeatures < ActiveRecord::Migration
  def self.up
    create_table :features, :force=>true do |t|
      
      t.column :description, :text
      
      # flag for shutting this feature on/off in the public view
      t.column :is_public, :boolean, :default=>false
      
      # The ordering number in reference to other items within this branch/level
      t.column :position, :integer, :default=>0
      
      # pid is the persistant ID (THDL fid)
      t.column :pid, :string, :null => false
      
      t.column :ancestor_ids, :string
      
      t.timestamps
    end
    
    add_index :features, :pid, :unique=>true
    add_index :features, :ancestor_ids
    add_index :features, :is_public
    
  end
  
  def self.down
    remove_index :features, :pid
    remove_index :features, :is_public
    remove_index :features, :ancestor_ids
    drop_table :features
  end
end