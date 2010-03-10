#
# This module can be extended by any ActiveRecord
# class that needs notes
#
module IsNotable
  
  def self.extended(base)
    
    base.has_many :notes, :as => :notable, :dependent => :destroy
    
  end
  
end