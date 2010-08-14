class TopicsController < ApplicationController
  # GET /topics/1
  # GET /topics/1.xml
  def show
    @category = Category.find(params[:id])
    join = @category.root.id==20 ? :feature_object_types : :category_features    
    @features = Feature.all(:conditions => {'category_features.category_id' => @category.id}, :joins => join)
    @title = "Features Associated to #{@category.title}"
    respond_to do |format|
      format.html { render :template => 'features/list' } # show.html.erb
    end
  end
end
