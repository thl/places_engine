class CreateFeatureRelationTypes < ActiveRecord::Migration
  def self.up
    create_table :feature_relation_types do |t|
      t.boolean :is_symmetric
      t.string :label
      t.string :asymmetric_label

      t.timestamps
    end
  end

  def self.down
    drop_table :feature_relation_types
  end
end
