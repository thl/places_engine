class DropInfoSources < ActiveRecord::Migration[5.2]
  def self.up
    drop_table :info_sources
  end
  
  def self.down
    create_table :info_sources, :force=>true do |t|
      t.column :code, :string, :null=>false
      t.column :title, :string
      t.column :agent, :string
      t.column :date_published, :date
      t.timestamps
    end
    add_index :info_sources, :code, :unique=>true
  end
end
