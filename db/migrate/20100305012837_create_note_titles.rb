class CreateNoteTitles < ActiveRecord::Migration
  def self.up
    create_table :note_titles do |t|
      t.string :title

      t.timestamps
    end
  end

  def self.down
    drop_table :note_titles
  end
end
