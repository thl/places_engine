class NoteTitle < ActiveRecord::Base
  validates_presence_of :title
  has_many :notes
  
  def to_s
    self.title
  end

  def self.search(filter_value, options={})
    options[:conditions] = build_like_conditions(
      %W(title),
      filter_value
    )
    paginate(options)
  end  
end

# == Schema Info
# Schema version: 20100609203100
#
# Table name: note_titles
#
#  id         :integer         not null, primary key
#  title      :string(255)
#  created_at :timestamp
#  updated_at :timestamp