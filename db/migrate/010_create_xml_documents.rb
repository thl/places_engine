class CreateXmlDocuments < ActiveRecord::Migration
  def self.up
    create_table :xml_documents do |t|
      t.integer :feature_id, :null=>false
      t.text :document, :null=>false
      t.timestamps
    end
    
    add_index :xml_documents, :feature_id
    
  end

  def self.down
    remove_index :xml_documents, :feature_id
    drop_table :xml_documents
  end
end