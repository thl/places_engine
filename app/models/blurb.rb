class Blurb < ActiveRecord::Base
  attr_accessible :title, :code, :content
  
  #
  #
  # Validation
  #
  #
  validates_format_of :code, :with=>/\w+/
  validates_uniqueness_of :code
  
  def to_s
    code.to_s
  end
  
  def self.search(filter_value)
    where(build_like_conditions(%W(blurbs.code blurbs.title blurbs.content), filter_value))
  end
end

# == Schema Info
# Schema version: 20110923232332
#
# Table name: blurbs
#
#  id         :integer         not null, primary key
#  code       :string(255)
#  content    :text
#  title      :string(255)
#  created_at :timestamp
#  updated_at :timestamp