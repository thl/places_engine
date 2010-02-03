# This controller handles the login/logout function of the site.  
class SessionsController < ApplicationController  
  # GET /session/new
  def new
    @session = Session.new(:login => '', :password => '', :remember_me => false)
  end
  
  # GET /session/edit
  def edit
    @session = Session.new(
      :perspective_id => self.current_perspective.id,
      :view_id => self.current_view.id,
      :show_feature_details => self.current_show_feature_details,
      :show_advanced_search => self.current_show_advanced_search)
    @perspectives = Perspective.find_all_public
    @views = View.find(:all, :order => 'name')
  end
  
  # POST /session
  def create
    session = Session.new(params[:session])
    #if using_open_id?
    #  open_id_authentication(params[:openid_url])
    #else
      password_authentication(session.login, session.password)
    #end
  end
  
  # PUT /session
  def update
    session = Session.new(params[:session])
    self.current_perspective_id = session.perspective_id
    self.current_view_id = session.view_id
    self.current_show_advanced_search = session.show_advanced_search
    self.current_show_feature_details = session.show_feature_details
    redirect_to root_path
  end
  
  # DELETE /session
  def destroy
    self.current_user.forget_me if logged_in?
    cookies.delete :auth_token
    reset_session
    flash[:notice] = "You have been logged out."
    redirect_back_or_default(root_url)
  end
  
  protected
  
  def open_id_authentication(openid_url)
    authenticate_with_open_id(openid_url, :required => [:nickname, :email]) do |result, identity_url, registration|
      if result.successful?
        @user = User.find_by_identity_url(identity_url)
        if @user.nil?
          failed_login result.message
        else
          self.current_user = @user
          successful_login
        end
      else
        failed_login result.message
      end
    end
  end
  
  def password_authentication(login, password)
    self.current_user = User.authenticate(login, password)
    if logged_in?
      successful_login
    else
      failed_login
    end
  end
  
  def failed_login(message = "Authentication failed.")
    flash.now[:notice] = message
    render :action => 'new'
  end
  
  def successful_login
    if params[:remember_me] == "1"
      self.current_user.remember_me
      cookies[:auth_token] = { :value => self.current_user.remember_token , :expires => self.current_user.remember_token_expires_at }
    end
    redirect_back_or_default(root_url)
    flash[:notice] = "Logged in successfully"
  end
end