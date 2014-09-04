class AddCountWithShapesToCachedCategoryCount < ActiveRecord::Migration
  def self.up
    CachedCategoryCount.connection.execute('TRUNCATE TABLE cached_category_counts')
    add_column :cached_category_counts, :count_with_shapes, :integer, :null => false
    CachedCategoryCount.reset_column_information
    FeatureObjectType.select('DISTINCT(category_id)').order('category_id').collect(&:category_id).each { |category_id| CachedCategoryCount.updated_count(category_id) }
  end

  def self.down
    remove_column :cached_category_counts, :count_with_shapes
  end
end