class Admin::UsersController < ApplicationController
  before_filter :find_person, :except => 'index'
  
  # GET /users
  def index
    redirect_to admin_people_url
  end

  # GET /people/1/user
  # GET /people/1/user.xml
  def show
    @user = @person.user
    respond_to do |format|
      format.html # show.rhtml
      format.xml  { render :xml => @user.to_xml }
    end
  end

  # GET /people/1/user/edit
  def edit
    @user = @person.user
  end
    
  # GET /people/1/user/new
  # GET /people/1/user/new.xml
  def new
    @user = @person.build_user
  end
  
  def openid_new
  end
  
  # POST /people/1/user
  # POST /people/1/user.xml
  def create
    if using_open_id?
      authenticate_with_open_id(params['openid_url'], :required => [:nickname, :email]) do |result, identity_url, registration|
        if result.successful?
          @user = AuthenticatedSystem::User.find_by_identity_url(identity_url)
          if @user.nil?
            @user = AuthenticatedSystem::User.new do |u|
              u.identity_url = identity_url
              u.login = registration['nickname']
              u.email = registration['email']
            end
            render :action => 'new'
          else
            flash[:notice] = "Identity URL already used by another user!"
            render :action => 'openid_new'
          end
        else
          flash[:notice] = "Could not validate identity URL!"
          render :action => 'openid_new'
        end
      end
    else
      @user = @person.build_user(params[:authenticated_system_user])
      @user.save!
      flash[:notice] = "User succesfully created!"
      redirect_to admin_person_url(@person)
    end
  rescue ActiveRecord::RecordInvalid
    render :action => 'new'
  end

  # PUT /people/1/user
  # PUT /people/1/user.xml
  def update
    @user = @person.user
    respond_to do |format|
      if @user.update_attributes(params[:authenticated_system_user])
        flash[:notice] = 'User was successfully updated.'
        format.html { redirect_to admin_people_url }
        format.xml  { head :ok }
      else
        format.html do
          render :action => 'edit' 
        end
        format.xml  { render :xml => @user.errors.to_xml }
      end
    end
  end

  # DELETE /people/1/user
  # DELETE /people/1/user.xml
  def destroy
    @user = @person.user
    @user.destroy

    respond_to do |format|
      format.html { redirect_to admin_people_url }
      format.xml  { head :ok }
    end
  end
  
  private
  
  def find_person
    person_id = params[:person_id]
    @person = person_id.blank? ? nil : AuthenticatedSystem::Person.find(person_id)
  end
end