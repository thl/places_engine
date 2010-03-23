class Admin::FeatureNamesController < ResourceController::Base
  
  belongs_to :feature
  
  before_filter :collection, :only=>:locate_for_relation
  
  def locate_for_relation
    @locating_relation=true # flag used in template
    @object = object
    @parent_object = parent_object
    # Remove the Feature that is currently looking for a relation
    # (shouldn't relate to itself)
    @collection.delete object
    render :action=>:index
  end
  
  def prioritize
    @feature = Feature.find(params[:id])
  end
  
  def set_priorities
    feature = Feature.find(params[:id])
    feature.names.each { |name| name.update_attribute(:position, params['feature_name'].index(name.id.to_s) + 1) }
    feature.update_is_name_position_overriden
    render :nothing => true
  end
  
  # Overwrite the default destroy method so we can redirect_to(:back)
  def destroy
    @name = FeatureName.find(params[:id])      
    @name.destroy
    redirect_to(:back)
  end
  
  protected
  
  #
  # Need to override the ResourceController::Helpers.parent_association method
  # to get the correct name of the parent association
  #
  def parent_association
    # needed for the show view
    @parent_object = parent_object
    parent_object.names
  end
  
  #
  # Override ResourceController collection method
  #
  def collection
    # needed for the list view
    @parent_object = parent_object if parent?
    
    feature_id=nil
    if params[:feature_id]
      feature_id = params[:feature_id]
    elsif params[:id]
      feature_id = object.feature_id
    end
    
    if feature_id
      @collection = FeatureName.send(:with_scope, :find=>{:conditions=>['feature_id = ?', feature_id]}) do
        FeatureName.search(params[:filter], :page=>params[:page])
      end
    else
      @collection = FeatureName.search(params[:filter], :page=>params[:page])
    end
    
  end
  
end