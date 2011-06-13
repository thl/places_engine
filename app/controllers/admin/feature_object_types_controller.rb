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
    mca_cats = mca_hash[:category_id].split(',')
    errors = []
    @feature = Feature.find(params[:feature_id])
    mca_cats.each do |c|
      unless c.blank?
        c = c.to_i
        mca_hash_temp = mca_hash
        mca_hash_temp[:category_id] = c
        mca_hash_temp[:feature_id] = @feature.id
        @cf = FeatureObjectType.new(mca_hash_temp)
        begin
          @cf.save
        rescue ActiveRecord::StatementInvalid
          # ignore duplicate issues. how to add ignore parameter to sql query here without changing to sql completely?
        else
         #errors.push( @cf.errors )
        end
      end
    end
    #puts "ez: #{errors}"
    respond_to do |format|
      unless errors.length > 0
        flash[:notice] = 'Success!'
        format.html { redirect_to admin_feature_url(@feature) }
      else
        flash[:notice] = errors.join(', ')
        format.html { render :action => "new" }
      end
    end
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