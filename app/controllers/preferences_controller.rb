class PreferencesController < ApplicationController

  protect_from_forgery :except => :edit
  
  def edit
    session[:name_preferences][:filter] = params[:name_preferences_filter]
    render :nothing => true, :status => 200
  end
end
