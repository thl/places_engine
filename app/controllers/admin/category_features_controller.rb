class Admin::CategoryFeaturesController < AclController
  include KmapsEngine::ResourceObjectAuthentication
  resource_controller

  belongs_to :feature
  
  def create
    mca_hash = params[:category_feature]
    mca_cats = mca_hash[:category_id]
    @feature = Feature.find(params[:feature_id])
    if mca_cats.nil?
      redirect_to admin_feature_url(@feature.fid)
    elsif mca_cats.size==1
      mca_hash[:category_id] = mca_cats.first
      @cf = @feature.category_features.new(mca_hash.permit(:category_id, :string_value, :numeric_value, :show_parent, :show_root, :label, :prefix_label))
      respond_to do |format|
        if @cf.save
          format.html { redirect_to admin_feature_url(@feature.fid) }
        else
          format.html { render :action => "new" }
        end
      end
    else
      mca_cats.each { |c_id| @feature.category_features.create(:category_id => c_id) }
      redirect_to admin_feature_url(@feature.fid)
    end
  end
  
  def collection
    filter = params[:filter]
    search_results = parent? ? CategoryFeature.contextual_search(filter, parent_object.id) : CategoryFeature.search(filter)
    @collection = search_results.page(params[:page])
  end
  
  protected
  
  # Only allow a trusted parameter "white list" through.
  def category_feature_params
    params.require(:category_feature).permit(:prefix_label, :label, :string_value, :numeric_value, :show_parent, :category_id, :show_root, :skip_update)
  end
  
  private
  
  def category_feature_params
    binding.pry
    params.permit(:category_id)
  end
  
  def build_object
    if object_params.nil?
      @object ||= end_of_association_chain.send :build
    else
      @object ||= end_of_association_chain.send :build, object_params
    end
  end
end
