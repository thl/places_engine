class AddEstimateToAltitude < ActiveRecord::Migration
  def self.up
    add_column :altitudes, :estimate, :string
  end

  def self.down
    remove_column :altitudes, :estimate
  end
end
