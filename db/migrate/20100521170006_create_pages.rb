class CreatePages < ActiveRecord::Migration
  def self.up
    remove_column :citations, :pages
    create_table :pages do |t|
      t.integer :citation_id
      t.integer :volume
      t.integer :start_page
      t.integer :start_line
      t.integer :end_page
      t.integer :end_line

      t.timestamps
    end
  end

  def self.down
    drop_table :pages
    add_column :citations, :pages
  end
end
