class Admin::FeatureObjectTypesController < ResourceController::Base
  helper :admin, 'admin/category_features'  
  belongs_to :feature
  
  new_action.before do
    @parent_object_type = Category.find(20) # feature thesaurus id in topical map builder
  end

  edit.before do
    @parent_object_type = Category.find(20) # feature thesaurus id in topical map builder
  end
  
  def collection
    @parent_object ||= parent_object
    page = params[:page]
    filter = params[:filter]
    if parent?
      @collection = FeatureObjectType.contextual_search(filter, @parent_object.id, :page=>page)
    else
      @collection = FeatureObjectType.search(filter, :page=>page)
    end
  end
  
  def prioritize
    @feature = Feature.find(params[:id])
  end
  
  def set_priorities
    feature = Feature.find(params[:id])
    feature.feature_object_types.each { |fot| fot.update_attribute(:position, params['feature_object_type'].index(fot.id.to_s) + 1) }
    render :nothing => true
  end
end