class Admin::UsersController < ApplicationController
  # GET /users
  # GET /users.xml
  def index
    @users = User.find(:all, :order => "UPPER(login)")
    respond_to do |format|
      format.html # index.rhtml
      format.xml  { render :xml => @users.to_xml }
    end
  end

  # GET /users/1
  # GET /users/1.xml
  def show
    @user = User.find(params[:id])
    respond_to do |format|
      format.html # show.rhtml
      format.xml  { render :xml => @user.to_xml }
    end
  end

  # GET /users/1;edit
  def edit
    @user = User.find(params[:id])
  end
    
  # render new.rhtml
  def new
    @user = User.new
  end
  
  def create
    @user = User.new(params[:user])
    @user.save!
    flash[:notice] = "User succesfully created!"
    redirect_to admin_user_url(@user)
  rescue ActiveRecord::RecordInvalid
    render :action => 'new'
  end

  # PUT /users/1
  # PUT /users/1.xml
  def update
    @user = User.find(params[:id])
    respond_to do |format|
      if @user.update_attributes(params[:user])
        flash[:notice] = 'User was successfully updated.'
        format.html { redirect_to admin_user_url(@user) }
        format.xml  { head :ok }
      else
        format.html do
          render :action => 'edit' 
        end
        format.xml  { render :xml => @user.errors.to_xml }
      end
    end
  end

  # DELETE /users/1
  # DELETE /users/1.xml
  def destroy
    @user = User.find(params[:id])
    @user.destroy

    respond_to do |format|
      format.html { redirect_to admin_users_url }
      format.xml  { head :ok }
    end
  end
end