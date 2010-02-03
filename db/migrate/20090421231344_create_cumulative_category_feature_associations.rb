class CreateCumulativeCategoryFeatureAssociations < ActiveRecord::Migration
  def self.up
    create_table :cumulative_category_feature_associations do |t|
      t.integer :feature_id, :null => false
      t.integer :category_id, :null => false
      t.timestamps
    end
    add_index :cumulative_category_feature_associations, [:category_id, :feature_id], :unique => true, :name => 'by_category_feature'
    say "To create cumulative associations please run:\nrake "
  end

  def self.down
    drop_table :cumulative_category_feature_associations
  end
end
