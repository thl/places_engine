require 'digest/sha1'
class User < ActiveRecord::Base
  has_and_belongs_to_many :descriptions, :join_table => 'authors_descriptions'
  has_and_belongs_to_many :notes, :join_table => 'authors_notes', :association_foreign_key => 'note_id'
 
  # Virtual attribute for the unencrypted password
  attr_accessor :password

  validates_presence_of     :login, :email
  validates_presence_of     :password,                   :if => :password_required?
  validates_presence_of     :password_confirmation,      :if => :password_required?
  validates_length_of       :password, :within => 4..40, :if => :password_required?
  validates_confirmation_of :password,                   :if => :password_required?
  validates_length_of       :login,    :within => 3..40
  validates_length_of       :email,    :within => 3..100
  validates_uniqueness_of   :login, :email, :case_sensitive => false
  before_save :encrypt_password
  
  # prevents a user from submitting a crafted form that bypasses activation
  # anything else you want your user to change should be added here.
  attr_accessible :login, :email, :password, :password_confirmation, :identity_url, :fullname

  # Authenticates a user by their login name and unencrypted password.  Returns the user or nil.
  def self.authenticate(login, password)
    u = find_by_login(login) # need to get the salt
    u && u.authenticated?(password) ? u : nil
  end

  # Encrypts some data with the salt.
  def self.encrypt(password, salt)
    Digest::SHA1.hexdigest("--#{salt}--#{password}--")
  end

  # Encrypts the password with the user salt
  def encrypt(password)
    self.class.encrypt(password, salt)
  end

  def authenticated?(password)
    crypted_password == encrypt(password)
  end

  def remember_token?
    remember_token_expires_at && Time.now.utc < remember_token_expires_at 
  end

  # These create and unset the fields required for remembering users between browser closes
  def remember_me
    remember_me_for 2.weeks
  end

  def remember_me_for(time)
    remember_me_until time.from_now.utc
  end

  def remember_me_until(time)
    self.remember_token_expires_at = time
    self.remember_token            = encrypt("#{email}--#{remember_token_expires_at}")
    save(false)
  end

  def forget_me
    self.remember_token_expires_at = nil
    self.remember_token            = nil
    save(false)
  end
  
  # Return true/false if User is authorized for resource.
  def authorized?(resource)
    return permission_strings.include?(resource)
  end
    
  def screen_name  
  	fullname.nil? ? login : fullname
  end
      
  protected
    # before filter 
    def encrypt_password
      return if password.blank?
      self.salt = Digest::SHA1.hexdigest("--#{Time.now.to_s}--#{login}--") if new_record?
      self.crypted_password = encrypt(password)
    end
      
    def password_required?
      crypted_password.blank? || !password.blank?
    end
end

# == Schema Info
# Schema version: 20100525230844
#
# Table name: users
#
#  id                        :integer         not null, primary key
#  person_id                 :integer
#  crypted_password          :string(40)      not null
#  email                     :string(255)     not null
#  fullname                  :string(255)
#  identity_url              :string(255)
#  login                     :string(255)     not null
#  remember_token            :string(255)
#  salt                      :string(40)
#  created_at                :timestamp
#  remember_token_expires_at :timestamp
#  updated_at                :timestamp