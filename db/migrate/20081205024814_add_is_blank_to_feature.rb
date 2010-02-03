class AddIsBlankToFeature < ActiveRecord::Migration
  def self.up
    add_column :features, :is_blank, :boolean, :null => false, :default => false
    Feature.reset_column_information
    Feature.blank.each do |f|
      f.is_blank = true
      f.save
    end
  end

  def self.down
    remove_column :features, :is_blank
  end
end
