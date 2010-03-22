class CreateNotes < ActiveRecord::Migration
  def self.up
    create_table :notes do |t|
      t.string :notable_type
      t.integer :notable_id
      t.integer :note_title_id
      t.string :custom_note_title
      t.text :content

      t.timestamps
    end
  end

  def self.down
    drop_table :notes
  end
end
