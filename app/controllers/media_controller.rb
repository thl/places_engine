class MediaController < ApplicationController
  # GET /media/1
  # GET /media/1.xml
  def show
    @medium = Medium.find(params[:id])
    if @medium.nil?
      redirect_to features_url
    else
      set_common_variables(session)
      @features = Feature.paginate(:conditions => {'features.fid' => Medium.find(@medium.id).feature_ids, 'cached_feature_names.view_id' => current_view.id}, :include => {:cached_feature_names => :feature_name}, :order => 'feature_names.name', :page => params[:page] || 1, :per_page => 15)
      @object_type = "Media"
      @object_title = "Medium #{@medium.id}"
      @object_url = Medium.element_url(@medium.id, :format => 'html')
      @feature = Feature.find(session[:interface][:context_id]) unless session[:interface][:context_id].blank?
      respond_to do |format|
        format.html { render :template => 'features/list' } # show.html.erb
      end
    end
  end
end
