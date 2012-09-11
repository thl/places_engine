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
    fids = params[:feature_id].split(/\D+/)
    fids.shift if fids.size>0 && fids.first.blank?    
    topic_ids = params[:id].split(/\D+/)
    perspective_code = params[:perspective_code]
    topic_ids.shift if topic_ids.size>0 && topic_ids.first.blank?
    if perspective_code.blank?
      feature = Feature.get_by_fid(fids.first)
      @features = feature.all_descendants_by_topic(topic_ids)      
    else
      perspective = Perspective.get_by_code(perspective_code)
      features_with_parents = Feature.descendants_by_perspective_and_topics(fids, perspective, topic_ids)
    end
    @view = params[:view_code].nil? ? current_view : View.get_by_code(params[:view_code])
    respond_to do |format|
      format.xml  { render :template => 'features/index' }
      format.json { render :json => Hash.from_xml(render_to_string(:template => 'features/index.xml.builder')) }
      format.txt do
        text = features_with_parents.collect do |f|
          s = "#{f[0].prioritized_name(@view).name} ("
          s << "#{f[1].prioritized_name(@view).name} - " if !f[1].nil?
          s << "#{f[0].feature_object_types.first.category.title}) {#{f[0].fid}}"
        end.join("\n")
        render :text => text
      end
    end
  end
end
