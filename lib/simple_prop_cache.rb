module SimplePropCache
  def self.included(base)
    base.extend ClassMethods
  end
  
  module ClassMethods
    def get_all
      @cache_for_all ||= self.find(:all, :order => 'created_at')
    end
    
    def get_by_code(code)
      @cache_by_codes ||= {}
      prop = @cache_by_codes[code]
      if prop.nil?
        prop = self.find_by_code(code)
        @cache_by_codes[code] = prop if !prop.nil?
      end
      return prop
    end
    
    def get_by_name(name)
      @cache_by_names ||= {}
      prop = @cache_by_names[name]
      if prop.nil?
        prop = self.find_by_name(name)
        @cache_by_names[name] = prop if !prop.nil?
      end
      return prop
    end
    
    def get_by_code_or_name(code, name)
      if code.blank?
        code = nil if !code.nil?
        prop = name.blank? ? nil : self.get_by_name(name)
      else
        name = nil if !name.nil?
        prop = code.blank? ? nil : self.get_by_code(code)
      end
      if prop.nil?
        identifier = code || name
        raise "#{self.human_name.capitalize} #{identifier} not found." if !identifier.blank?
      end
      prop
    end
  end
end