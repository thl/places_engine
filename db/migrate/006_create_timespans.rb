class CreateTimespans < ActiveRecord::Migration
  def self.up
    create_table :timespans, :force=>true do |t|
      t.date :start_date, :end_date
      t.integer :start_date_fuzz, :end_date_fuzz
      t.boolean :is_current, :default=>true
      t.integer :dateable_id
      t.string :dateable_type
      t.timestamps
    end
    
    add_index :timespans, [:dateable_id,:dateable_type]
    add_index :timespans, :start_date
    add_index :timespans, :end_date
    
  end

  def self.down
    remove_index :timespans, :start_date
    remove_index :timespans, :end_date
    drop_table :timespans
  end
end