class Perspective < ActiveRecord::Base
  include SimplePropCache
    
  #
  #
  # Associations
  #
  #
  extend IsCitable
  extend HasTimespan
  
  #
  #
  # Validation
  #
  #
  validates_presence_of :name
  validates_format_of :code, :with=>/\w+/
  validates_uniqueness_of :code
      
  def to_s
    name
  end
  
  def self.name_and_id_list
    find(:all).collect {|ft| [ft.name, ft.id] }
  end
  
  def self.search(filter_value, options={})
    options[:conditions] = build_like_conditions(
      %W(simple_props.name simple_props.code simple_props.description simple_props.notes),
      filter_value
    )
    paginate(options)
  end

  def self.find_all_public
    find(:all, :order => 'name', :conditions => {:is_public => true})
  end
  
end

# == Schema Info
# Schema version: 20100525230844
#
# Table name: perspectives
#
#  id          :integer         not null, primary key
#  code        :string(255)
#  description :text
#  is_public   :boolean
#  name        :string(255)
#  notes       :text
#  created_at  :timestamp
#  updated_at  :timestamp