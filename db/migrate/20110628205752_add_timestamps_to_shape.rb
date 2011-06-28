class AddTimestampsToShape < ActiveRecord::Migration
  def self.up
    change_table(:shapes) { |t| t.timestamps }
  end

  def self.down
    change_table(:shapes) { |t| t.remove_timestamps }
  end
end
