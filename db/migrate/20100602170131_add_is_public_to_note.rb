class AddIsPublicToNote < ActiveRecord::Migration
  def self.up
    add_column :notes, :is_public, :boolean, :default => true
    AssociationNote.update_all :is_public => true
    Note.update_all :is_public => true
  end

  def self.down
    remove_column :notes, :is_public
  end
end
