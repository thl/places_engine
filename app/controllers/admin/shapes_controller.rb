class Admin::ShapesController < ResourceController::Base
  belongs_to :feature
  
  def update
    load_object
    geo = @object.geometry
    geo.lat = params[:shape][:lat] if !params[:shape][:lat].blank? && params[:shape][:lat].to_f > 0.0
    geo.lng = params[:shape][:lng] if !params[:shape][:lng].blank? && params[:shape][:lng].to_f > 0.0
    @object.geometry = geo
    if @object.save
      set_flash :update
    else
      set_flash :update_fails
    end
    redirect_to collection_path
  end
  
  # update.response do | wants |
  #   wants.html { redirect_to collection_path }
  # end

  def prioritize
    @feature = Feature.find(params[:id])
  end
  
  def set_priorities
    feature = Feature.find(params[:id])
    feature.shapes.each { |shape| shape.update_attribute(:position, params['feature_shape'].index(shape.id.to_s) + 1) }
    render :nothing => true
  end
  
  protected
  
    def object
      @object = Shape.find(params[:id])
      @parent_object = @object.feature
      @object
    end
  
    # def parent_association
    #   @parent_object=parent_object # ResourceController normally sets this
    #   if params[:id].nil?
    #     return parent_object.parent_relations 
    #   end
    #   # Gotta find it seperately, will get a recursive stack error elsewise
    #   o = Shape.find(params[:id])
    #   parent_object.id == o.parent_node.id ? parent_object.child_relations : parent_object.parent_relations
    # end

    def collection
      # needed for the list view
      @parent_object = parent_object if parent?
      @collection = Shape.find_all_by_feature_id(params[:feature_id])
    end
end
