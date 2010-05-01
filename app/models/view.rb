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


# == Schema Info
# Schema version: 20100428184445
#
# Table name: simple_props
#
#  id          :integer         not null, primary key
#  code        :string(255)
#  description :text
#  name        :string(255)
#  notes       :text
#  type        :string(255)
#  created_at  :timestamp
#  updated_at  :timestamp