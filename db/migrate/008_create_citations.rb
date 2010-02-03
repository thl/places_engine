class CreateCitations < ActiveRecord::Migration
  def self.up
    create_table :citations, :force=>true do |t|
      t.integer :info_source_id
      
      # Citations are polymorphic - so we need to save the type of citation (class) and the id
      t.string :citable_type
      t.integer :citable_id
      
      # This needs to be named something else, "class" wreaks havoc!
      #t.string :class
      
      t.string :pages
      t.text :notes
      t.timestamps
    end
    
    add_index :citations, [:citable_id,:citable_type]
    add_index :citations, :info_source_id
    
  end

  def self.down
    remove_index :citations, [:citable_id,:citable_type]
    remove_index :citations, :info_source_id
    drop_table :citations
  end
end