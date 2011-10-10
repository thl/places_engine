class TopicsController < ApplicationController
  caches_page :feature_descendants
  
  # GET /topics/1
  # GET /topics/1.xml
  def show
    set_common_variables(session)

    @category = Category.find(params[:id])
    @object_type = "Topic"
    @object_title = @category.title
    @object_url = Category.element_url(@category.id, :format => 'html')
    @features = Feature.paginate(:conditions => {'cumulative_category_feature_associations.category_id' => @category.id, 'cached_feature_names.view_id' => current_view.id}, :joins => :cumulative_category_feature_associations, :include => {:cached_feature_names => :feature_name}, :order => 'feature_names.name', :page => params[:page] || 1, :per_page => 15)
    @feature = Feature.find(session[:interface][:context_id]) unless session[:interface][:context_id].blank?

    if request.xhr?
      render :partial => 'features/list'
    else
      respond_to do |format|
        format.html { render :template => 'features/list' }
      end
    end
  end
  
  def feature_descendants
    feature = Feature.get_by_fid(params[:feature_id])
    topic = Topic.find(params[:id])
    @features = feature.all_descendants_by_topic(topic)
    @view = params[:view_code].nil? ? nil : View.get_by_code(params[:view_code])
    respond_to do |format|
      format.xml  { render :template => 'features/index' }
      format.json { render :json => Hash.from_xml(render_to_string(:template => 'features/index.xml.builder')) }
    end
  end
end
