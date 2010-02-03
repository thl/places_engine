class CreateInfoSources < ActiveRecord::Migration
  def self.up
    create_table :info_sources, :force=>true do |t|
      t.column :code, :string, :null=>false
      t.column :title, :string
      t.column :agent, :string
      t.column :date_published, :date
      t.timestamps
    end
    
    add_index :info_sources, :code, :unique=>true
    
  end
  
  def self.down
    remove_index :info_sources, :code
    drop_table :info_sources
  end
end