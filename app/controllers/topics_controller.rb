class TopicsController < ApplicationController
  caches_page :feature_descendants
  
  # GET /topics/1
  # GET /topics/1.xml
  def show
    @category = Category.find(params[:id])
    if @category.nil?
      redirect_to features_url
    else
      set_common_variables(session)
      @object_type = Topic.human_name(:count => :many).titleize
      @object_title = @category.title
      @object_url = Category.element_url(@category.id, :format => 'html')
      @features = Feature.where('cumulative_category_feature_associations.category_id' => @category.id, 'cached_feature_names.view_id' => current_view.id).joins(:cumulative_category_feature_associations).includes(:cached_feature_names => :feature_name).paginate(:page => params[:page] || 1, :per_page => 15).order('feature_names.name')
      @feature = Feature.find(session[:interface][:context_id]) unless session[:interface][:context_id].blank?
      if request.xhr?
        render :partial => 'features/list'
      else
        respond_to do |format|
          format.html { render :template => 'features/list' }
        end
      end
    end
  end
  
  def feature_descendants
    feature = Feature.get_by_fid(params[:feature_id])
    topic_ids = params[:id].split(/\D+/)
    topic_ids.shift if topic_ids.size>0 && topic_ids.first.blank?    
    @features = feature.all_descendants_by_topic(topic_ids)
    @view = params[:view_code].nil? ? nil : View.get_by_code(params[:view_code])
    respond_to do |format|
      format.xml  { render :template => 'features/index' }
      format.json { render :json => Hash.from_xml(render_to_string(:template => 'features/index.xml.builder')) }
    end
  end
end
