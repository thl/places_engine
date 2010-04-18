class CreateCachedFeatureRelationCategories < ActiveRecord::Migration
  def self.up
    create_table :cached_feature_relation_categories do |t|
      t.integer :feature_id
      t.integer :related_feature_id
      t.integer :category_id
      t.string :role
      t.integer :perspective_id

      t.timestamps
    end
    say "To create cached feature relation categories, please run:\nrake db:cache:feature_relation_category:create"
  end

  def self.down
    drop_table :cached_feature_relation_categories
  end
end
