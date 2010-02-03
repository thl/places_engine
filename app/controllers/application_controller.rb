# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  uses_tiny_mce :options => { 
                  
   								:theme => 'advanced',
   								:theme_advanced_resizing => 'true',
   								:theme_advanced_toolbar_location => 'top', 
   								:theme_advanced_toolbar_align => 'left',
   								:theme_advanced_buttons1 => %w{fullscreen separator bold italic underline strikethrough separator undo redo separator link unlink  separator justifyleft justifycenter justifyright justifiyfull code},
   								:theme_advanced_buttons2 => %w{cut copy paste separator pastetext pasteword separator bullist numlist outdent indent separator  removeformat  charmap separator template formatselect },
   								:theme_advanced_buttons3 => [],
   								:plugins => %w{contextmenu paste media fullscreen template noneditable code },				
   								:template_external_list_url => '/templates/templates.js',
  								:noneditable_leave_contenteditable => 'true',
  								:theme_advanced_blockformats => 'p,h1,h2,h3,h4,h5,h6'
   							  }
 
  include AuthenticatedSystem
  include ExceptionNotifiable
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
  
end