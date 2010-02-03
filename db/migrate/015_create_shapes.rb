class CreateShapes < ActiveRecord::Migration
  def self.up
    create_table :shapes, :primary_key => :gid, :force => true do |t|
      t.column :geometry, :geometry, :srid => 4326
      t.column :fid, :string
    end

    add_index :shapes, [:geometry], :name => :features_geometry_gist, :spatial=> true 
  end

  def self.down
    drop_table :shapes
  end
end