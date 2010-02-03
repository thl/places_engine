class CreateDescriptions < ActiveRecord::Migration
  def self.up
    create_table :descriptions do |t|
      t.references :feature, :null => false
      t.text :content, :null => false
      t.boolean :is_primary, :null => false, :default => false
  
      t.timestamps
    end
    Feature.find(:all, :conditions => 'description IS NOT NULL').each {|f| f.descriptions.create(:content => f.description, :is_primary => true) if !f.description.blank?}
    #remove_column :features, :description
    
  end

  def self.down
    #add_column :features, :description, :text
    #Feature.reset_column_information
    #Feature.find(:all).each do |f| 
    #  if !f.descriptions.empty?
    #    content = f.descriptions.first.content
    #    f.description = content if !content.blank?
    #  end
    #end    
    drop_table :descriptions
  end
end
