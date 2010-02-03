class CreateCachedCategoryCounts < ActiveRecord::Migration
  def self.up
    create_table :cached_category_counts do |t|
      t.integer :category_id, :null => false
      t.integer :count, :null => false
      t.datetime :cache_updated_at, :null => false      
      t.timestamps
    end
    add_index :cached_category_counts, [:category_id], :unique => true
  end

  def self.down
    drop_table :cached_category_counts
  end
end
