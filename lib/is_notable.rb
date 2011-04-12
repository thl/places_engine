#
# This module can be extended by any ActiveRecord
# class that needs notes
#
module IsNotable
  
  def self.extended(base)
    
    base.has_many :notes, :as => :notable, :dependent => :destroy
    
    base.class_eval do
      
      def public_notes
        notes.find(:all, :conditions => {:is_public => true})
      end
      
    end
    
  end
  
end