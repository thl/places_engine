class CreatePerspectives < ActiveRecord::Migration
  def self.up
    create_table :perspectives do |t|
      t.string :name
      t.string :code
      t.text :description
      t.text :notes
      t.boolean :is_public, :default=>false
      t.timestamps
    end
    
    add_index :perspectives, :code
    
    old_perspectives = SimpleProp.where(:type => "Perspective")
    
    # Move Perspective records from simple_props into perspectives 
    # The Perspective model should be changed to inherit from ActiveRecord::Base, so that
    # this data migration will work.
    old_perspectives.each do |old|
      p = Perspective.new
      # Need to keep the id to preserve associations with other models
      p.id = old.id
      p.name = old.name
      p.code = old.code
      p.description = old.description
      p.notes = old.notes
      p.is_public = true
      p.created_at = old.created_at
      p.updated_at = old.updated_at
      p.save
      #SimpleProp.destroy(old.id)
    end
    
  end

  def self.down
    remove_index :perspectives, :code
    drop_table :perspectives
  end
end
