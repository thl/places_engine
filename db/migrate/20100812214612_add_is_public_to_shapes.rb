class AddIsPublicToShapes < ActiveRecord::Migration
  def self.up
    add_column :shapes, :is_public, :boolean, :null => false, :default => true
    Shape.reset_column_information
    g = GeoCodeType.get_by_code('bell.id')
    g.features.collect(&:shapes).each { |shapes| shapes.each { |s| s.update_attribute(:is_public, false) } } if !g.nil?
  end

  def self.down
    remove_column :shapes, :is_public
  end
end
