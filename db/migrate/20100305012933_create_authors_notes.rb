class CreateAuthorsNotes < ActiveRecord::Migration
  def self.up
    create_table :authors_notes, :id => false do |t|
      t.references :author, :null => false  # author is an User
      t.references  :note, :null => false  
    end
    add_index :authors_notes, [:author_id, :note_id], :unique => true
  end

  def self.down
    drop_table :authors_notes
  end
end
