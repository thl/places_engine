# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  include SessionManager
  
  protect_from_forgery
  before_filter :admin_authentication
  layout :choose_layout
  
  protected
  
  def is_admin_area?
    params[:controller] =~ /^admin/
  end
  
  def admin_authentication
    login_required if is_admin_area?
    #authenticate_or_request_with_http_basic do |username, password|
    #  username == 'gaz_admin' && password == 'gaz2008'
    #end
  end
  
  def choose_layout
    return 'admin' if is_admin_area?
    # if request.xhr?
    if ['show', 'feature'].include? params[:action]
      @no_layout = ! params[:no_layout].blank?
      return nil if @no_layout
    end
    'public'
  end

  def set_common_variables(session_params)

    session[:interface] ||= {}

    # Allow for views and perspectives to be set by GET params.  It might be possible to simplify this code...
    if params[:perspective_id] || params[:view_id]
      session = Session.new
      if params[:perspective_id]
        session.perspective_id = params[:perspective_id]
        self.current_perspective = Perspective.find(params[:perspective_id])
      end
      if params[:view_id]
        session.view_id = params[:view_id]
        self.current_view = View.find(params[:view_id])
      end
    end
    @top_level_nodes = Feature.current_roots(current_perspective, current_view)
    @session = Session.new(:perspective_id => self.current_perspective.id, :view_id => self.current_view.id)
    @perspectives = Perspective.find_all_public
    @views = View.order('name')

    search_defaults = {
    	:filter => '',
    	:scope => 'name',
    	:match => 'contains',
    	:search_scope => 'global',
    	:has_descriptions => '0'
    }

    # These are used to show the same search results that were on the previous page.
    @previous_search_params = session_params[:interface][:search_params] || search_defaults

    # These are used to show the same search form field values that were on the previous page.
    @search_form_params = search_defaults
  end
  
end