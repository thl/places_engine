#
# This module can be extended by any ActiveRecord
# class that needs citations
#
module IsCitable
  
  def self.extended(base)
    
    base.has_many :citations, :as => :citable, :dependent => :destroy
    
    base.class_eval do
      
      #
      # methods here...
      #
      def citations_attributes=(attrs=[])
        attrs.each do |i|
          self.citation_attributes=(i.last)
        end
      end
      
      #
      #
      #
      def citation_attributes=(attrs={})
        begin
          o = citations.find(attrs[:id])
          if attrs[:marked_for_deletion].to_s == '1'
            o.destroy
          else
            o.attributes=attrs
          end
        rescue
          citations.build(attrs)
        end
      end
      
    end
  end
  
end