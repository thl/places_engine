class AddLanguageIdToDescription < ActiveRecord::Migration
  def up
    add_column :descriptions, :language_id, :integer
    Description.reset_column_information
    eng = Language.get_by_code('eng').id
    Description.where(language_id: nil).update_all(language_id: eng)
    change_column :descriptions, :language_id, :integer, :null => false
  end
  
  def down
    remove_column :descriptions, :language_id
  end
end
