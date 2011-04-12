class Unit < PassiveRecord::Base
  extend IsOptionable

  schema :title => String, :id => Integer, :order => Integer
  
  create :title => 'Meters', :id => 1, :order => 1
  create :title => 'Feet', :id => 2, :order => 2
end