class TopicsController < ApplicationController
  allow_unauthenticated_access
  #caches_page :feature_descendants
  
  # GET /topics/1
  # GET /topics/1.xml
  def show
    @category = SubjectsIntegration::Feature.find(params[:id])
    if @category.nil?
      redirect_to features_url
    else
      set_common_variables
      @object_type = Topic.human_name(:count => :many).titleize
      @object_title = @category.header
      @object_url = SubjectsIntegration::SubjectsResource.get_url + "features/#{@category.id}"
      @features = Feature.where('cumulative_category_feature_associations.category_id' => @category.id, 'cached_feature_names.view_id' => current_view.id).joins(:cumulative_category_feature_associations).references(:cumulative_category_feature_associations).includes(:cached_feature_names => :feature_name).paginate(:page => params[:page] || 1, :per_page => params[:per_page] || 15).order('feature_names.name')
      respond_to do |format|
        format.html do
          @feature = Feature.find(session[:interface][:context_id]) unless session[:interface].blank? || session[:interface][:context_id].blank?
          render 'features/list'
        end
        format.js  { render template: 'features/paginated_list' }
        format.xml do
          @view = params[:view_code].nil? ? nil : View.get_by_code(params[:view_code])
          @view ||= View.get_by_code(default_view_code)
          render 'paginated_show', format: 'xml'
        end
        format.json do
          @view = params[:view_code].nil? ? nil : View.get_by_code(params[:view_code])
          @view ||= View.get_by_code(default_view_code)
          render json: Hash.from_xml(render_to_string(action: 'paginated_show', format: 'xml'))
        end
      end
    end
  end
  
  def feature_descendants
    fids = params[:feature_id].split(/\D+/)
    fids.shift if fids.size>0 && fids.first.blank?    
    topic_ids = params[:id].split(/\D+/)
    topic_ids.shift if topic_ids.size>0 && topic_ids.first.blank?
    respond_to do |format|
      format.xml do
        @features = Feature.descendants_by_topic(fids, topic_ids)
        render 'features/index'
      end
      format.json do
        @features = Feature.descendants_by_topic(fids, topic_ids)
        render json: Hash.from_xml(render_to_string(template: 'features/index', format: 'xml'))
      end
      format.txt do
        perspective_code = params[:perspective_code]
        @features_with_parents = perspective_code.blank? ? Feature.descendants_by_topic_with_parent(fids, topic_ids) : Feature.descendants_by_perspective_and_topics_with_parent(fids, Perspective.get_by_code(perspective_code), topic_ids)
        view_code_str = params[:view_code]
        if view_code_str.blank?
          @view = current_view
        else
          @view = view_code_str.split(',').collect{ |code| View.get_by_code(code) }
          @view = @view.first if @view.size==1
        end
        render 'features/descendants'
      end
      format.csv do
        perspective_code = params[:perspective_code]
        @features_with_parents = perspective_code.blank? ? Feature.descendants_by_topic_with_parent(fids, topic_ids) : Feature.descendants_by_perspective_and_topics_with_parent(fids, Perspective.get_by_code(perspective_code), topic_ids)
      end
    end
  end
end