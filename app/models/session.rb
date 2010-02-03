class Session
  attr_accessor :login, :password, :remember_me, :perspective_id, :view_id, :show_feature_details, :show_advanced_search
  
  def initialize(params={})
    params.each{|key, value| send("#{key}=",value)}
  end
end
