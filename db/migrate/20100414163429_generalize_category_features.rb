class GeneralizeCategoryFeatures < ActiveRecord::Migration
  def self.up
    rename_table :feature_object_types, :category_features
    change_table :category_features do |t|
      t.rename :object_type_id, :category_id
      t.string :type
    end
    CategoryFeature.update_all("type = 'FeatureObjectType'")
  end

  def self.down
    rename_table :category_features, :feature_object_types
    change_table :feature_object_types do |t|
      t.rename :category_id, :object_type_id
      t.remove :type
    end
  end
end
