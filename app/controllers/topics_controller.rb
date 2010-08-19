class TopicsController < ApplicationController
  # GET /topics/1
  # GET /topics/1.xml
  def show
    set_common_variables(session)
    @category = Category.find(params[:id])
    join = @category.root.id==20 ? :feature_object_types : :category_features    
    @features = Feature.all(:conditions => {'category_features.category_id' => @category.id}, :joins => join)
    @object_type = "Topic"
    @object_title = @category.title
    @object_url = Category.element_url(@category.id, :format => 'html')
    
    @feature = Feature.find(session[:interface][:context_id]) unless session[:interface][:context_id].blank?
    respond_to do |format|
      format.html { render :template => 'features/list' } # show.html.erb
    end
  end
end
