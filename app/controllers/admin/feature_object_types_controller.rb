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
  
  def create
    mca_hash = feature_object_type_params
    mca_cats = mca_hash[:category_id]
    errors = []
    @feature = Feature.find(params[:feature_id])
    if mca_cats.nil?
      redirect_to admin_feature_url(@feature.fid)
    elsif mca_cats.size==1
      mca_hash[:category_id] = mca_cats.first
      @cf = @feature.feature_object_types.new(mca_hash)
      respond_to do |format|
        if @cf.save
          format.html { redirect_to admin_feature_url(@feature.fid) }
        else
          format.html { render :action => "new" }
        end
      end
    else
      mca_cats.each { |c_id| @feature.feature_object_types.create(:category_id => c_id) }
      redirect_to admin_feature_url(@feature.fid)
    end
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
    params.require(:feature_object_type).permit(:string_value, :numeric_value, :show_parent, :show_root, :label, :prefix_label, category_id: [])
  end
end
