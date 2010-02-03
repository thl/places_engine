class CreateSimpleProps < ActiveRecord::Migration
  def self.up
    create_table :simple_props do |t|
      t.string :name
      t.string :code
      t.text :description
      t.text :notes
      t.string :type
      t.timestamps
    end
    
    add_index :simple_props, :type
    add_index :simple_props, :code
    
  end

  def self.down
    remove_index :simple_props, :type
    remove_index :simple_props, :code
    drop_table :simple_props
  end
end