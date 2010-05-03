class AddStringValueAndNumericValueToCategoryFeatures < ActiveRecord::Migration
  def self.up
    change_table :category_features do |t|
      t.string :string_value
      t.integer :numeric_value
    end
  end

  def self.down
    change_table :category_features do |t|
      t.remove :string_value
      t.remove :numeric_value
    end    
  end
end
