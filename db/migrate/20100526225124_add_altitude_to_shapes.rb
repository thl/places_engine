class AddAltitudeToShapes < ActiveRecord::Migration
  def self.up
    add_column :shapes, :altitude, :integer
  end

  def self.down
    remove_column :shapes, :altitude
  end
end
