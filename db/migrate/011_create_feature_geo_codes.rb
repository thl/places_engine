class CreateFeatureGeoCodes < ActiveRecord::Migration
  
  def self.up
    create_table :feature_geo_codes do |t|
      t.integer :feature_id, :geo_code_type_id, :timespan_id
      t.string :geo_code_value
      t.text :notes
      t.timestamps
    end
  end

  def self.down
    drop_table :feature_geo_codes
  end
  
end