class Admin::CategoryFeaturesController < ResourceController::Base
  helper :admin
  belongs_to :feature
  
  def create
    mca_hash = params[:category_feature]
    mca_cats = mca_hash[:category_id]
    errors = []
    @feature = Feature.find(params[:feature_id])
    if mca_cats.nil?
      redirect_to admin_feature_url(@feature)
    elsif mca_cats.size==1
      mca_hash[:category_id] = mca_cats.first
      @cf = @feature.category_features.new(mca_hash)
      respond_to do |format|
        if @cf.save
          format.html { redirect_to admin_feature_url(@feature) }
        else
          format.html { render :action => "new" }
        end
      end
    else
      mca_cats.each { |c_id| @feature.category_features.create(:category_id => c_id) }
      redirect_to admin_feature_url(@feature)
    end    
  end
  
  def collection
    @parent_object ||= parent_object
    filter = params[:filter]
    search_results = parent? ? CategoryFeature.contextual_search(filter, @parent_object.id) : CategoryFeature.search(filter)
    @collection = search_results.page(params[:page])
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
