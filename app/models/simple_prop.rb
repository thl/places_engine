# now Language has all attributes and methods of SimpleProp
# end
#
# The class name that extends SimpleProp is stored in the :type column
# All data is stored in simple_props
# See Rails STI (Single Table Inheritance)
#
class SimpleProp < ActiveRecord::Base
  include SimplePropCache
  
  #
  #
  # Associations
  #
  #
  
  #
  #
  # Validation
  #
  #
  validates_format_of :code, :with=>/\w+/
  # Validate only within the same class type
  validates_uniqueness_of :code, :scope=>:type
  
  def self.name_and_id_list
    find(:all).collect {|ft| [ft.name, ft.id] }
  end
  
  def to_s
    [name, code, 'n/a'].detect {|i| ! i.blank? }
  end
  
  def self.search(filter_value, options={})
    options[:conditions] = build_like_conditions(
      %W(simple_props.name simple_props.code simple_props.description simple_props.notes),
      filter_value
    )
    paginate(options)
  end  
end

# == Schema Info
# Schema version: 20100623234636
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