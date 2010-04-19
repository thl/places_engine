class Admin::CategoryFeaturesController < ResourceController::Base
  helper :admin
  belongs_to :feature
  
  def collection
    @parent_object ||= parent_object
    page = params[:page]
    filter = params[:filter]
    if parent?
      @collection = CategoryFeature.contextual_search(filter, @parent_object.id, :page=>page)
    else
      @collection = CategoryFeature.search(filter, :page=>page)
    end
  end
  
  private
  
  def build_object
    if object_params.nil?
      @object ||= end_of_association_chain.send :build
    else
      @object ||= end_of_association_chain.send :build, object_params
    end
  end
end
