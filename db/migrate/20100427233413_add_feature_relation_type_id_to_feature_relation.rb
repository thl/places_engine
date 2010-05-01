class AddFeatureRelationTypeIdToFeatureRelation < ActiveRecord::Migration
  def self.up
    add_column :feature_relations, :feature_relation_type_id, :integer
  end

  def self.down
    remove_column :feature_relations, :feature_relation_type_id
  end
end
