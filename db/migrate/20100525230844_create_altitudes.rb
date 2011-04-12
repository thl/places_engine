class CreateAltitudes < ActiveRecord::Migration
  def self.up
    create_table :altitudes do |t|
      t.integer :feature_id, :null => false
      t.integer :maximum
      t.integer :minimum
      t.integer :average
      t.integer :unit_id, :null => false

      t.timestamps
    end
  end

  def self.down
    drop_table :altitudes
  end
end
