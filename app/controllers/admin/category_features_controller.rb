class Admin::CategoryFeaturesController < ResourceController::Base
  helper :admin
  belongs_to :feature
  
  def create
    mca_hash = params[:category_feature]
    mca_cats = mca_hash[:category_id].split(',')
    errors = []
    @feature = Feature.find(params[:feature_id])
    mca_cats.each do |c|
      unless c.blank?
        c = c.to_i
        mca_hash_temp = mca_hash
        mca_hash_temp[:category_id] = c
        mca_hash_temp[:feature_id] = @feature.id
        @cf = CategoryFeature.new(mca_hash_temp)
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
