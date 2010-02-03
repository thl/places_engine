class ChangeFeatureNameEtymologyToText < ActiveRecord::Migration
  def self.up
    change_column :feature_names, :etymology, :text
  end

  def self.down
    change_column :feature_names, :etymology, :string
  end
end
