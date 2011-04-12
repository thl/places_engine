module SimplePropCache
  def self.included(base)
    base.extend ClassMethods
  end
  
  module ClassMethods
    def get_all
      Rails.cache.fetch("#{self.model_name}/all") { self.find(:all, :order => 'created_at') }
    end
    
    def get_by_code(code)
      Rails.cache.fetch("simple-props-code/#{code}") { self.find_by_code(code) }
    end
    
    def get_by_name(name)
      Rails.cache.fetch("#{self.model_name}-name/#{name}") { self.find_by_name(name) }
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