class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users, :force => true do |t|
      t.string :login, :null => false
      t.string :email, :null => false
      t.integer :person_id
      t.string :crypted_password, :limit => 40, :null => false
      t.string :salt, :limit => 40
      t.string :remember_token
      t.datetime :remember_token_expires_at      
      t.timestamps
    end
    User.create :login => 'gaz_admin', :password => 'gaz2008', :password_confirmation => 'gaz2008', :email => 'root@'
  end

  def self.down
    drop_table :users
  end
end
