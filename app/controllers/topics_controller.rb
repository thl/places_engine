class TopicsController < ApplicationController
  # GET /topics/1
  # GET /topics/1.xml
  def show
    set_common_variables(session)

    @category = Category.find(params[:id])
    @object_type = "Topic"
    @object_title = @category.title
    @object_url = Category.element_url(@category.id, :format => 'html')

    join = @category.root.id==20 ? :feature_object_types : :category_features
    @features = Feature.paginate(:conditions => {'category_features.category_id' => @category.id, 'cached_feature_names.view_id' => current_view.id}, :joins => join, :include => {:cached_feature_names => :feature_name}, :order => 'feature_names.name', :page => params[:page] || 1, :per_page => 15)
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
