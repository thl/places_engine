module SessionManager
  protected
  def current_perspective
    perspective_id = session[:perspective_id]
    begin
      if perspective_id.blank?
        @@current_perspective = Perspective.get_by_code('pol.admin.hier') if !defined?(@@current_perspect) || @@current_perspective.nil? || @@current_perspective.code != 'pol.admin.hier'
      else
        @@current_perspective = Perspective.find(perspective_id) if !defined?(@@current_perspect) || @@current_perspective.nil? || @@current_perspective.id != perspective_id
      end
    rescue ActiveRecord::RecordNotFound
      session[:perspective_id] = nil
      @@current_perspective = Perspective.get_by_code('pol.admin.hier')
    end
    return @@current_perspective
  end
  
  def current_perspective=(perspective)
    session[:perspective_id] = perspective.id
  end
  
  def current_perspective_id=(perspective_id)
    session[:perspective_id] = perspective_id
  end

  def current_view
    view_id = session[:view_id]
    begin
      if view_id.blank?
        @@current_view = View.get_by_code('roman.popular') if !defined?(@@current_view) || @@current_view.nil? || @@current_view.code != 'roman.popular'
      else
        @@current_view = View.find(view_id) if !defined?(@@current_view) || @@current_view.nil? || @@current_view.id != view_id
      end
    rescue ActiveRecord::RecordNotFound
      session[:view_id] = nil
      @@current_view = View.get_by_code('roman.popular')
    end
    return @@current_view
  end
  
  def current_view=(view)
    session[:view_id] = view.id
  end
  
  def current_view_id=(view_id)
    session[:view_id] = view_id
  end
  
  def current_show_advanced_search
    session[:show_advanced_search].nil? ? false : session[:show_advanced_search]
  end
  
  def current_show_advanced_search=(show_advanced_search)
    session[:show_advanced_search] = ['true', true, '1', 1].include?(show_advanced_search) ? true : false
  end
  
  def current_show_feature_details
    session[:show_feature_details].nil? ? false : session[:show_feature_details]
  end
  
  def current_show_feature_details=(show_feature_details)
    session[:show_feature_details] = ['true', true, '1', 1].include?(show_feature_details) ? true : false
  end
  
  # Inclusion hook to make #current_perspective
  # available as ActionView helper method.
  def self.included(base)
    base.send :helper_method, :current_perspective
    base.send :helper_method, :current_view
    base.send :helper_method, :current_show_feature_details
    base.send :helper_method, :current_show_advanced_search
  end
end