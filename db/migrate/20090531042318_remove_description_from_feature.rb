class RemoveDescriptionFromFeature < ActiveRecord::Migration
  def self.up
    remove_column :features, :description
  end

  def self.down
    add_column :features, :description, :text
  end
end
