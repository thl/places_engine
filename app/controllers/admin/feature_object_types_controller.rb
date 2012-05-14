class Admin::FeatureObjectTypesController < ResourceController::Base
  helper :admin, 'admin/category_features'  
  belongs_to :feature
  
  new_action.before do
    @parent_object_type = Category.find(20) # feature thesaurus id in topical map builder
  end

  edit.before do
    @parent_object_type = Category.find(20) # feature thesaurus id in topical map builder
  end
  
  def create
    mca_hash = params[:feature_object_type]
    mca_cats = mca_hash[:category_id]
    errors = []
    @feature = Feature.find(params[:feature_id])
    if mca_cats.nil?
      redirect_to admin_feature_url(@feature)
    elsif mca_cats.size==1
      mca_hash[:category_id] = mca_cats.first
      @cf = @feature.feature_object_types.new(mca_hash)
      respond_to do |format|
        if @cf.save
          format.html { redirect_to admin_feature_url(@feature) }
        else
          format.html { render :action => "new" }
        end
      end
    else
      mca_cats.each { |c_id| @feature.feature_object_types.create(:category_id => c_id) }
      redirect_to admin_feature_url(@feature)
    end    
  end

  def collection
    @parent_object ||= parent_object
    page = params[:page]
    filter = params[:filter]
    if parent?
      @collection = FeatureObjectType.contextual_search(filter, @parent_object.id).page(page)
    else
      @collection = FeatureObjectType.search(filter).page(page)
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