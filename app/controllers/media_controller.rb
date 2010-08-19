class MediaController < ApplicationController
  # GET /media/1
  # GET /media/1.xml
  def show
    set_common_variables(session)
    @medium = Medium.find(params[:id])
    @features = Feature.find_all_by_medium_id(@medium.id)
    @object_type = "Medium"
    @object_title = "Medium #{@medium.id}"
    @object_url = Medium.element_url(@medium.id, :format => 'html')
       
    @feature = Feature.find(session[:interface][:context_id]) unless session[:interface][:context_id].blank?
    respond_to do |format|
      format.html { render :template => 'features/list' } # show.html.erb
    end
  end
end
