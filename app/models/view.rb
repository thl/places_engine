# == Schema Information
# Schema version: 20091102185045
#
# Table name: simple_props
#
#  id          :integer         not null, primary key
#  name        :string(255)
#  code        :string(255)
#  description :text
#  notes       :text
#  type        :string(255)
#  created_at  :timestamp
#  updated_at  :timestamp
#

class View < SimpleProp
  
  #
  #
  # Associations
  #
  #
  has_many :cached_feature_names
  
  extend IsCitable
  extend HasTimespan
  
  #
  #
  # Validation
  #
  #
  validates_presence_of :name
    
  def to_s
    name
  end
  
end
