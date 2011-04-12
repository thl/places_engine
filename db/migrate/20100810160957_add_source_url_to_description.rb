class AddSourceUrlToDescription < ActiveRecord::Migration
  def self.up
    add_column :descriptions, :source_url, :string
  end

  def self.down
    remove_column :descriptions, :source_url
  end
end
