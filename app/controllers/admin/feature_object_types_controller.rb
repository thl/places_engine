class Admin::FeatureObjectTypesController < AclController
  include KmapsEngine::ResourceObjectAuthentication
  resource_controller
  
  helper :admin, 'admin/category_features'
  belongs_to :feature
  
  new_action.before do
    @parent_object_type = SubjectsIntegration::Feature.find(FeatureObjectType::BRANCH_ID) # feature thesaurus id in topical map builder
  end

  edit.before do
    @parent_object_type = SubjectsIntegration::Feature.find(FeatureObjectType::BRANCH_ID) # feature thesaurus id in topical map builder
  end
  
  def collection
    page = params[:page]
    filter = params[:filter]
    if parent?
      @collection = FeatureObjectType.contextual_search(filter, parent_object.id).page(page)
    else
      @collection = FeatureObjectType.search(filter).page(page)
    end
  end
  
  def prioritize
    @feature = Feature.find(params[:id])
  end
  
  def set_priorities
    feature = Feature.find(params[:id])
    feature_object_type_ids_params = params[:feature_object_type]
    feature.feature_object_types.each { |fot| fot.update_attribute(:position, feature_object_type_ids_params.index(fot.id.to_s) + 1) }
    render plain: ''
  end

  def feature_object_type_params
    params.require(:feature_object_type).permit(:string_value, :numeric_value, :show_parent, :show_root, :label, :prefix_label, :category_id)
  end
end
