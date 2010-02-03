class CreateContestations < ActiveRecord::Migration
  def self.up
    create_table :contestations do |t|
      t.references :feature, :null => false
      t.boolean :contested, :null => false, :default => true
      t.integer :administrator_id
      t.integer :claimant_id

      t.timestamps
    end
  end

  def self.down
    drop_table :contestations
  end
end
