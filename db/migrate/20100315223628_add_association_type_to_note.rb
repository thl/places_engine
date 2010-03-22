class AddAssociationTypeToNote < ActiveRecord::Migration
  def self.up
    add_column :notes, :association_type, :string
  end

  def self.down
    remove_column :notes, :association_type
  end
end
