class AddFeatureRelationTypeIdToCachedFeatureRelationCategory < ActiveRecord::Migration
  def self.up
    remove_column :cached_feature_relation_categories, :role
    add_column :cached_feature_relation_categories, :feature_relation_type_id, :integer
    add_column :cached_feature_relation_categories, :feature_is_parent, :boolean
    say "Cached feature relation categories should be updated by running:\nrake db:cache:feature_relation_category:create"
  end

  def self.down
    remove_column :cached_feature_relation_categories, :feature_relation_type_id
    remove_column :cached_feature_relation_categories, :feature_is_parent
    add_column :cached_feature_relation_categories, :role, :string
  end
end
