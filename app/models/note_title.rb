class NoteTitle < ActiveRecord::Base
  attr_accessible :title
  
  validates_presence_of :title
  has_many :notes
  
  def to_s
    self.title
  end

  def self.search(filter_value)
    self.where(build_like_conditions(%W(title), filter_value))
  end  
end

# == Schema Info
# Schema version: 20110923232332
#
# Table name: note_titles
#
#  id         :integer         not null, primary key
#  title      :string(255)
#  created_at :timestamp
#  updated_at :timestamp