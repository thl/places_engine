class MediaController < ApplicationController
  # GET /media/1
  # GET /media/1.xml
  def show
    @medium = MmsIntegration::Medium.find(params[:id])
    if @medium.nil?
      redirect_to features_url
    else
      @features = Feature.where('features.fid' => MmsIntegration::Medium.find(@medium.id).feature_ids, 'cached_feature_names.view_id' => current_view.id).includes(:cached_feature_names => :feature_name).references(:cached_feature_names => :feature_name).paginate(:page => params[:page] || 1, :per_page => 15).order('feature_names.name')
      @object_type = "Media"
      @object_title = "Medium #{@medium.id}"
      @object_url = MmsIntegration::Medium.element_url(@medium.id, :format => 'html')
      @feature = Feature.find(session['interface']['context_id']) unless session['interface'].blank? || session['interface']['context_id'].blank?
      respond_to do |format|
        format.html { render :template => 'features/list' } # show.html.erb
        format.js   { render :template => 'features/paginated_list' }
      end
    end
  end
end
