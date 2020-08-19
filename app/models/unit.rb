class Unit
  include KmapsEngine::PassiveRecord
  
  attr_accessor :title, :order
  
  create title: 'Meters', order: 1
  create title: 'Feet', order: 2
end