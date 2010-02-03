class FeaturePid
  attr_accessor :count
  
  def initialize(params)
    params.each{|key, value| send("#{key}=",value) }
  end
end
